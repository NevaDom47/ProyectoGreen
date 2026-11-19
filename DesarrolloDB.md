# DesarrolloDB — Arquitectura PostgreSQL y PostgREST (`app_mercadito`)

> **Motor**: PostgreSQL (15/16+) + **PostgREST**
> **Última actualización**: 2026-11-18
> **Propósito**: Documento vivo rector para todo desarrollo que involucre diseño de tablas, vistas, funciones RPC, índices, políticas RLS o consumo de datos vía **PostgREST** en **El Mercadito**.

---

## 1. Regla de Uso y Actualización Continua

Cada vez que se solicite una funcionalidad que requiera persistencia, consulta, escritura o analítica de datos:
1. **`lead-orchestrator`** y **`backend-core-specialist`** deben consultar este documento antes de proponer contratos o repositorios.
2. Toda nueva tabla, columna, migración, vista, función RPC, índice, política RLS o endpoint PostgREST debe **registrarse obligatoriamente** en la Sección 5 (*Historial de Cambios DB*) y reflejarse en el esquema de referencia de la Sección 3.
3. No se permiten consultas sin proyección explícita (`?select=`), tablas sin `RLS` ni filtros frecuentes sin su índice correspondiente.

---

## 2. Mejores Prácticas y Optimización en PostgreSQL + PostgREST

### 2.1 Convenciones de Esquema y Tipos de Datos
- **Nomenclatura**: `snake_case` siempre en minúsculas; tablas en plural (`users`, `products`, `coupons`, `orders`).
- **Identificadores**:
  - Clave primaria interna: `id UUID PRIMARY KEY DEFAULT gen_random_uuid()` (inmutable, segura para RLS y exposición REST).
  - Código legible de negocio (cuando aplique): `code TEXT UNIQUE NOT NULL` con índice único (ej. `BUY-00000001`, `PROV-00000001`, `TUB-PAP-01`, `COSECHA10`).
- **Montos Monetarios y Cantidades**:
  - Usar siempre `NUMERIC(12, 2)` para precios, descuentos, subtotales e importes en `RD$` (prohibido `REAL` o `DOUBLE PRECISION` para dinero).
  - Cantidades o pesos en `NUMERIC(12, 3)` para soportar decimales en kilogramos/libras.
- **Fechas y Zonas Horarias**:
  - Usar siempre `TIMESTAMPTZ` (almacenado en UTC); utilizar `DEFAULT now()`.
  - Para horarios comerciales diarios (`DaySchedule`), usar `TIME` junto con `day_of_week SMALLINT CHECK (day_of_week BETWEEN 1 AND 7)`.
- **Geolocalización**:
  - Coordenadas de proveedores en `latitude DOUBLE PRECISION` y `longitude DOUBLE PRECISION` (o `GEOGRAPHY(Point, 4326)` con PostGIS si está habilitado) indexadas para búsquedas de radio cercano en `providers_map_screen`.
- **Integridad Referencial y Auditoría**:
  - Incluir `created_at TIMESTAMPTZ NOT NULL DEFAULT now()` y `updated_at TIMESTAMPTZ NOT NULL DEFAULT now()` (con trigger compartido `set_updated_at()`).
  - Preferir `ENUM` o `TEXT` con `CHECK (...)` explícito alineado a los enums de Dart (`CouponStatus`, `NotificationPriority`, `PriceMarketStatus`, etc.).

### 2.2 Optimización de Consultas HTTP en PostgREST
- **Proyección Vertical Estricta (`?select=`)**:
  - **Prohibido** consumir `/tabla` sin `?select=`. Solicitar únicamente las columnas necesarias para la vista o modelo Dart:
    ```http
    GET /products?select=id,sku,name,retail_price,wholesale_price,quality_tier,image_url,is_active&is_active=eq.true
    ```
- **Resource Embedding (Evitar N+1 Queries)**:
  - Aprovechar las Foreign Keys para embeber relaciones en una sola llamada HTTP. Usar `!inner` cuando se requiera filtrado tipo `INNER JOIN`:
    ```http
    GET /products?select=id,name,retail_price,provider:provider_profiles!inner(id,public_code,commercial_name,is_verified,rating_avg)&provider.is_verified=eq.true
    ```
- **Paginación Obligatoria (Keyset / Cursor & Range)**:
  - Toda colección (`home_feed`, `search`, `notifications`, `chat_messages`, `order_history`) debe paginarse.
  - Preferir **Keyset Pagination** (por cursor de `created_at` e `id`) para feeds infinitos o chats (evita el costo de `OFFSET` alto):
    ```http
    GET /chat_messages?select=id,sender_id,body,created_at&conversation_id=eq.<uuid>&created_at=lt.2026-11-18T12:00:00Z&order=created_at.desc&limit=30
    ```
  - Cuando se use `Range` (`Range: 0-19`) y se requiera estimado total, usar cabecera `Prefer: count=planned` en lugar de `count=exact` en tablas con alto volumen para evitar *sequential scans*.
- **Operaciones Transaccionales con RPC (`POST /rpc/<funcion>`)**:
  - Cualquier operación que afecte múltiples tablas o requiera bloqueo atómico (`FOR UPDATE`) debe implementarse como función `PL/pgSQL` `SECURITY DEFINER` o `SECURITY INVOKER` expuesta por PostgREST en `/rpc/`:
    - `POST /rpc/redeem_coupon` (valida vigencia, audiencia, compra mínima, límites globales/por usuario, inserta `coupon_redemptions` e incrementa contadores atómicamente).
    - `POST /rpc/accept_negotiation_offer` (cierra negociación, genera orden e ítems en una sola transacción).
    - `POST /rpc/recalculate_buyer_behavior` (actualiza `buyer_behavior_profiles` con mediana, método preferido, índice mayorista y decaimiento temporal $e^{-\lambda t}$).
    - `POST /rpc/calculate_provider_response_metrics` (ventana móvil de las últimas 50-100 atenciones calculada únicamente dentro del horario configurado en `provider_schedules`).
- **Vistas y Vistas Materializadas (`VIEW` / `MATERIALIZED VIEW`)**:
  - Exponer vistas dedicadas (ej. `v_public_provider_cards`, `v_active_flash_offers`) para encapsular joins complejos y respetar `user_privacy_settings`.
  - Para métricas analíticas pesadas (`coupon_analytics`, tendencias de precios de cultivos, resúmenes del `dashboard_screen`), usar `MATERIALIZED VIEW` refrescadas periódicamente con `REFRESH MATERIALIZED VIEW CONCURRENTLY`.
- **Preferencias de Escritura PostgREST**:
  - En `POST` / `PATCH`, enviar `Prefer: return=representation` solo cuando el repositorio Dart necesite el registro persistido; usar `Prefer: return=minimal` en eventos de telemetría o marcado de lectura (`is_read = true`) para ahorrar ancho de banda.

### 2.3 Estándares de Indexación (Indexing)
1. **Foreign Keys**: Todo campo `*_id` con clave foránea **debe** tener índice `B-Tree` explícito (PostgreSQL no indexa FKs automáticamente).
2. **Índices Parciales y Compuestos para Consultas Calientes**:
   - Catálogo activo por categoría y fecha:
     `CREATE INDEX idx_products_active_cat ON products (category, created_at DESC) WHERE is_active = true;`
   - Ofertas relámpago vigentes ordenadas por vencimiento:
     `CREATE INDEX idx_flash_offers_active_end ON flash_offers (ends_at ASC) WHERE status = 'active';`
   - Notificaciones no leídas por usuario:
     `CREATE INDEX idx_notifications_unread ON notifications (user_id, created_at DESC) WHERE is_read = false;`
   - Cupones activos por proveedor:
     `CREATE INDEX idx_coupons_provider_active ON coupons (provider_id, end_date) WHERE status = 'active';`
3. **Búsqueda de Texto y Etiquetas (`GIN` + `pg_trgm`)**:
   - Habilitar `CREATE EXTENSION IF NOT EXISTS pg_trgm;` y crear índices `GIN` sobre `products (name gin_trgm_ops)`, `standard_catalog_products USING GIN (aliases)` y `products USING GIN (tags)`.
4. **Geoespacial (`GiST` / PostGIS)**:
   - Índice `GIST` sobre ubicación geográfica de `provider_profiles` para filtrar proveedores cercanos en el mapa.

### 2.4 Seguridad y Row Level Security (RLS)
- **Regla Cero Fugas**: Todas las tablas en el esquema expuesto por PostgREST deben tener:
  ```sql
  ALTER TABLE <nombre_tabla> ENABLE ROW LEVEL SECURITY;
  ```
- **Identidad JWT**: PostgREST inyecta los claims del token en `current_setting('request.jwt.claims', true)::jsonb`. Se recomienda crear funciones helper en esquema privado (`app_auth.current_user_id()`, `app_auth.current_role()`).
- **Principio de Mínimo Privilegio**:
  - Tablas privadas (`carts`, `orders`, `notifications`, `user_reports`, `provider_verifications`): lectura y escritura restringida al propietario (`buyer_id` / `provider_id` / `user_id = current_user_id()`).
  - Reglas de negocio reforzadas en DB (ej. un cupón solo es editable vía `UPDATE` si `status = 'paused' AND has_been_activated = false`; una reseña de negociación solo se inserta si han transcurrido `>= 3 days` desde `completed_at`).
  - Privacidad pública: Las vistas públicas de perfiles deben evaluar `buyer_privacy_settings` y `provider_privacy_settings` en el servidor, nunca delegar el ocultamiento únicamente al frontend.

---

## 3. Arquitectura Relacional Base del Proyecto (Mapeo de Dominios)

El siguiente modelo relacional cubre los dominios actualmente implementados en `app_mercadito/lib/` y sirve como plano maestro para las migraciones SQL.

### Bloque 1: Usuarios, Perfiles, Horarios, Privacidad y Verificación Comercial
- **`users`**: `id UUID PK`, `public_code TEXT UNIQUE` (`BUY-00000001` / `PROV-00000001`), `role TEXT CHECK (role IN ('comprador','proveedor'))`, `full_name`, `email UNIQUE`, `phone`, `country`, `state_province`, `street_address`, `birth_date DATE`, `is_email_verified BOOLEAN`, `has_adult_consent BOOLEAN`, `profile_picture_url`, `created_at`, `updated_at`.
- **`buyer_profiles`**: `user_id UUID PK FK -> users(id)`, `loyalty_level`, `is_onboarded BOOLEAN`.
- **`provider_profiles`**: `user_id UUID PK FK -> users(id)`, `commercial_name`, `specialty`, `sales_type TEXT CHECK (sales_type IN ('Mayorista','Al Detalle','Ambos'))`, `business_description`, `banner_picture_url`, `sector`, `latitude DOUBLE PRECISION`, `longitude DOUBLE PRECISION`, `rating_avg NUMERIC(3,2)`, `reviews_count INT`, `traded_count INT`, `level TEXT`, `is_verified BOOLEAN DEFAULT false`, `business_name_last_changed_at TIMESTAMPTZ`, `is_onboarded BOOLEAN`.
- **`provider_schedules`**: `id UUID PK`, `provider_id UUID FK -> provider_profiles(user_id)`, `day_of_week SMALLINT`, `day_name TEXT`, `is_active BOOLEAN`, `open_time TIME`, `close_time TIME`, `UNIQUE(provider_id, day_of_week)`.
- **`provider_verifications`**: `id UUID PK`, `provider_id UUID FK`, `commercial_name`, `rnc_number`, `dgii_status`, `document_type`, `document_url`, `address_proof_url`, `representative_id_url`, `status TEXT CHECK (status IN ('not_submitted','pending','verified','rejected'))`, `rejection_reason`, `rejection_count INT DEFAULT 0`, `lockout_until TIMESTAMPTZ`, `submitted_at TIMESTAMPTZ`.
- **`user_privacy_settings`**: `user_id UUID PK FK -> users(id)`, `buyer_settings JSONB`, `provider_settings JSONB`, `updated_at`.
- **`provider_policies`**: `id UUID PK`, `provider_id UUID FK`, `policy_text TEXT`, `sort_order INT`, `is_active BOOLEAN`.

### Bloque 2: Catálogo Estándar, Productos, Verificación EXIF y Ofertas Relámpago
- **`standard_catalog_products`**: `id UUID PK`, `code TEXT UNIQUE`, `name`, `category`, `default_unit`, `sku_prefix`, `aliases TEXT[]` (índice `GIN`), `reference_retail_price NUMERIC(12,2)`, `reference_wholesale_price NUMERIC(12,2)`, `sample_image_url`, `description`.
- **`products`**: `id UUID PK`, `provider_id UUID FK`, `catalog_product_id UUID FK NULL`, `sku TEXT UNIQUE`, `name`, `category`, `quality_tier TEXT CHECK (quality_tier IN ('Primera Calidad','Segunda Calidad','Tercera Calidad'))`, `sales_mode TEXT CHECK (sales_mode IN ('retail_only','wholesale_only','both'))`, `retail_price NUMERIC(12,2)`, `old_retail_price NUMERIC(12,2)`, `retail_unit TEXT`, `wholesale_price NUMERIC(12,2)`, `old_wholesale_price NUMERIC(12,2)`, `wholesale_unit TEXT`, `wholesale_min_qty NUMERIC(12,3)`, `available_units TEXT[]`, `tags TEXT[]`, `image_url TEXT`, `exif_verified_live BOOLEAN DEFAULT false`, `exif_confidence_score INT DEFAULT 0`, `is_active BOOLEAN DEFAULT true`, `created_at`, `updated_at`.
- **`flash_offers`**: `id UUID PK`, `product_id UUID FK -> products(id)`, `provider_id UUID FK`, `discount_percent INT CHECK (discount_percent BETWEEN 1 AND 95)`, `offer_retail_price NUMERIC(12,2)`, `offer_wholesale_price NUMERIC(12,2)`, `starts_at TIMESTAMPTZ`, `ends_at TIMESTAMPTZ`, `status TEXT CHECK (status IN ('scheduled','active','expired','paused'))`, `created_at`.

### Bloque 3: Sistema de Cupones y Redenciones
- **`coupons`**: `id UUID PK`, `provider_id UUID FK`, `code TEXT NOT NULL`, `title TEXT NOT NULL`, `category TEXT DEFAULT 'GENERAL'`, `icon_code_point INT`, `benefit_type TEXT CHECK (benefit_type IN ('percentage','fixedAmount','freeShipping','twoForOne','giftProduct','specialPrice'))`, `benefit_value NUMERIC(12,2) DEFAULT 0`, `custom_gift_name TEXT`, `special_price_label TEXT`, `scope TEXT CHECK (scope IN ('allProducts','specificProducts','specificCategories'))`, `target_product_ids UUID[]`, `target_categories TEXT[]`, `min_purchase NUMERIC(12,2) DEFAULT 0`, `total_usage_limit INT DEFAULT 100`, `usage_per_buyer INT DEFAULT 1`, `start_date TIMESTAMPTZ`, `end_date TIMESTAMPTZ`, `applicable_days SMALLINT[]`, `audience TEXT CHECK (audience IN ('allBuyers','newBuyers','frequentBuyers','inactiveBuyers','selectedBuyers'))`, `inactive_days_threshold INT DEFAULT 60`, `selected_buyer_ids UUID[]`, `status TEXT CHECK (status IN ('active','paused','expired','depleted'))`, `has_been_activated BOOLEAN DEFAULT false`, `published_count INT DEFAULT 0`, `views_count INT DEFAULT 0`, `saved_count INT DEFAULT 0`, `redeemed_count INT DEFAULT 0`, `sales_generated NUMERIC(12,2) DEFAULT 0`, `discount_given NUMERIC(12,2) DEFAULT 0`, `new_buyers_acquired INT DEFAULT 0`, `created_at`, `UNIQUE(provider_id, code)`.
- **`coupon_redemptions`**: `id UUID PK`, `coupon_id UUID FK -> coupons(id)`, `buyer_id UUID FK -> users(id)`, `order_id UUID FK -> orders(id)`, `discount_amount NUMERIC(12,2)`, `order_amount NUMERIC(12,2)`, `product_details JSONB`, `is_expired BOOLEAN DEFAULT false`, `used_at TIMESTAMPTZ DEFAULT now()`.

### Bloque 4: Carrito, Negociaciones y Pedidos
- **`cart_items`**: `id UUID PK`, `buyer_id UUID FK -> users(id)`, `product_id UUID FK -> products(id)`, `is_wholesale BOOLEAN DEFAULT false`, `quantity NUMERIC(12,3) CHECK (quantity > 0)`, `unit_label TEXT`, `added_at TIMESTAMPTZ DEFAULT now()`, `UNIQUE(buyer_id, product_id, is_wholesale)`.
- **`negotiations`**: `id UUID PK`, `buyer_id UUID FK`, `provider_id UUID FK`, `product_id UUID FK`, `status TEXT CHECK (status IN ('open','counter_offer','accepted','rejected','expired'))`, `initial_price NUMERIC(12,2)`, `current_offer_price NUMERIC(12,2)`, `agreed_price NUMERIC(12,2)`, `quantity NUMERIC(12,3)`, `delivery_method TEXT`, `payment_terms TEXT`, `expires_at TIMESTAMPTZ`, `accepted_at TIMESTAMPTZ`, `created_at`, `updated_at`.
- **`negotiation_offers`**: `id UUID PK`, `negotiation_id UUID FK`, `sender_id UUID FK`, `proposed_price NUMERIC(12,2)`, `proposed_quantity NUMERIC(12,3)`, `note TEXT`, `created_at`.
- **`orders`**: `id UUID PK`, `order_code TEXT UNIQUE`, `buyer_id UUID FK`, `provider_id UUID FK`, `negotiation_id UUID FK NULL`, `coupon_id UUID FK NULL`, `subtotal NUMERIC(12,2)`, `discount_total NUMERIC(12,2)`, `total_amount NUMERIC(12,2)`, `payment_method TEXT`, `delivery_method TEXT`, `status TEXT CHECK (status IN ('pending','confirmed','in_transit','completed','cancelled'))`, `completed_at TIMESTAMPTZ`, `created_at`.
- **`order_items`**: `id UUID PK`, `order_id UUID FK -> orders(id) ON DELETE CASCADE`, `product_id UUID FK`, `sku TEXT`, `product_name TEXT`, `is_wholesale BOOLEAN`, `quantity NUMERIC(12,3)`, `unit_price NUMERIC(12,2)`, `line_total NUMERIC(12,2)`.

### Bloque 5: Chats y Métricas de Atención (SLA en Horario Laboral)
- **`chat_conversations`**: `id UUID PK`, `buyer_id UUID FK`, `provider_id UUID FK`, `last_message_at TIMESTAMPTZ`, `unread_buyer INT DEFAULT 0`, `unread_provider INT DEFAULT 0`, `UNIQUE(buyer_id, provider_id)`.
- **`chat_messages`**: `id UUID PK`, `conversation_id UUID FK`, `sender_id UUID FK`, `body TEXT`, `attachment_url TEXT`, `is_read BOOLEAN DEFAULT false`, `created_at TIMESTAMPTZ DEFAULT now()`.
- **`provider_attention_logs`**: `id UUID PK`, `provider_id UUID FK`, `conversation_id UUID FK`, `buyer_message_at TIMESTAMPTZ`, `provider_first_reply_at TIMESTAMPTZ`, `effective_response_minutes INT` (calculado respetando `provider_schedules`), `speed_points SMALLINT`, `was_answered BOOLEAN`.

### Bloque 6: Reseñas, Favoritos y Moderación (Reportes)
- **`product_negotiation_reviews`**: `id UUID PK`, `order_id UUID UNIQUE FK -> orders(id)`, `negotiation_id UUID FK NULL`, `product_id UUID FK`, `buyer_id UUID FK`, `provider_id UUID FK`, `rating SMALLINT CHECK (rating BETWEEN 1 AND 5)`, `comment TEXT`, `tags TEXT[]`, `user_photo_url TEXT`, `producer_reply TEXT`, `replied_at TIMESTAMPTZ`, `created_at TIMESTAMPTZ DEFAULT now()`. *(Validar en DB/trigger que `now() >= order.completed_at + interval '3 days'` antes de permitir insertar).*
- **`direct_profile_reviews`**: `id UUID PK`, `author_id UUID FK`, `target_user_id UUID FK`, `rating SMALLINT CHECK (rating BETWEEN 1 AND 5)`, `comment TEXT`, `tags TEXT[]`, `created_at`, `CHECK (author_id <> target_user_id)`.
- **`user_favorites`**: `id UUID PK`, `user_id UUID FK`, `target_type TEXT CHECK (target_type IN ('product','provider','buyer'))`, `target_id UUID NOT NULL`, `created_at`, `UNIQUE(user_id, target_type, target_id)`.
- **`user_reports`**: `id UUID PK`, `reporter_id UUID FK`, `reported_id UUID FK`, `reasons TEXT[] NOT NULL CHECK (cardinality(reasons) >= 1)`, `comment TEXT NOT NULL CHECK (char_length(trim(comment)) > 0 AND char_length(comment) <= 200)`, `status TEXT CHECK (status IN ('pending','in_review','resolved','dismissed')) DEFAULT 'pending'`, `resolution_notes TEXT`, `resolved_at TIMESTAMPTZ`, `created_at TIMESTAMPTZ DEFAULT now()`, `CHECK (reporter_id <> reported_id)`.

### Bloque 7: Mercado, Comportamiento de Compra, Notificaciones y Gamificación
- **`market_news`**: `id UUID PK`, `title`, `summary`, `commercial_analysis`, `source_name`, `source_url`, `category`, `trend TEXT CHECK (trend IN ('up','down','stable'))`, `trend_impact`, `related_products TEXT[]`, `image_url`, `read_time_minutes SMALLINT`, `published_at TIMESTAMPTZ`.
- **`crop_trend_predictions`**: `id UUID PK`, `crop_name`, `category`, `direction TEXT CHECK (direction IN ('alza','baja','sin_cambios'))`, `percentage_tag`, `forecast_summary`, `confidence_level`, `time_horizon`, `has_data BOOLEAN`, `source_name`, `source_url`, `updated_at`.
- **`buyer_purchase_events`**: `id UUID PK`, `order_id UUID FK`, `buyer_id UUID FK`, `product_name`, `category`, `quantity_kg NUMERIC(12,3)`, `is_wholesale BOOLEAN`, `payment_method`, `amount NUMERIC(12,2)`, `purchase_date TIMESTAMPTZ`.
- **`buyer_behavior_profiles`**: `buyer_id UUID PK FK -> users(id)`, `median_volume_kg NUMERIC(12,3)`, `volume_classification TEXT`, `volume_confidence_pct SMALLINT`, `preferred_payment_method TEXT`, `payment_confidence_pct SMALLINT`, `purchase_modality TEXT`, `wholesale_index_pct SMALLINT`, `modality_confidence_pct SMALLINT`, `frequent_products TEXT[]`, `frequent_categories TEXT[]`, `total_purchases_analyzed INT`, `recalculated_at TIMESTAMPTZ`.
- **`notifications`**: `id UUID PK`, `user_id UUID FK`, `title`, `description`, `why_it_matters`, `category TEXT`, `priority TEXT CHECK (priority IN ('urgent','important','info'))`, `actions JSONB`, `price_tag`, `media_url`, `is_video_media BOOLEAN DEFAULT false`, `group_key`, `group_count INT`, `is_read BOOLEAN DEFAULT false`, `is_action_completed BOOLEAN DEFAULT false`, `action_completed_message TEXT`, `created_at TIMESTAMPTZ DEFAULT now()`.
- **`notification_preferences`**: `user_id UUID PK FK -> users(id)`, `channel_settings JSONB`, `quiet_hours_start TIME`, `quiet_hours_end TIME`, `updated_at`.
- **`gamification_tasks`** y **`user_task_progress`**: `task_id`, `user_id`, `progress`, `streak_days`, `completed_at`, `claimed_at`.

---

## 4. Contratos de Integración Dart con PostgREST

1. **Separación de Capas**:
   - Interfaces abstractas en `lib/repositories/` (siguiendo el patrón de `IProviderMapRepository`).
   - Implementaciones concretas (`Postgrest*Repository`) en Dart puro sin importar `flutter/material.dart` ni `dart:ui`.
2. **Serialización Limpia**:
   - Usar mapeadores dedicados (`fromJson` / `toJson`) alineando nombres `camelCase` de Dart con columnas `snake_case` de PostgreSQL.
3. **Cabeceras Estándar PostgREST**:
   - `Authorization: Bearer <jwt>`
   - `Accept: application/json` / `Content-Type: application/json`
   - `Prefer: return=representation` (en inserts/updates que retornen el objeto creado) o `Prefer: return=minimal` (en updates de estado simples).
4. **Manejo de Errores Tipado**:
   - Mapear códigos HTTP (`400` validación, `401` sesión expirada, `403` violación RLS, `404` no encontrado, `409` conflicto único como código de cupón duplicado) a excepciones de dominio tipadas.

---

## 5. Historial de Cambios DB (Registro Obligatorio)

> Toda solicitud que modifique o agregue tablas, vistas, RPCs, índices, políticas RLS o endpoints PostgREST debe añadir una fila aquí.

| ID | Fecha | Módulo / Feature | Tablas / Vistas / RPCs Afectadas | Endpoint PostgREST & Consulta Optimizada | Índices y RLS Aplicados | Estado |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **DB-000** | 2026-11-18 | Arquitectura Base | Bloques 1–7 (Esquema maestro inicial de `app_mercadito`) | Definición de estándares `?select=`, embedding, keyset pagination y `/rpc/*` | Estándar `RLS` obligatorio en todas las tablas + índices FK, parciales, `GIN` y `GiST`. | Documentado (Pendiente de despliegue inicial en instancia PostgreSQL). |
