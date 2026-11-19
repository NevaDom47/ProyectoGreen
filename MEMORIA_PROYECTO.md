# MEMORIA DEL PROYECTO — El Mercadito (`app_mercadito`)

> **Última actualización**: 2026-11-18
> **Propósito**: Archivo maestro de contexto y memoria persistente del proyecto **El Mercadito**. Todo agente que intervenga en una solicitud debe leer este documento antes de diseñar, planificar o escribir código, y actualizarlo al cerrar cada entrega aprobada.

---

## 1. Protocolo Obligatorio para Agentes

1. **Antes de iniciar cualquier tarea**:
   - Leer `MEMORIA_PROYECTO.md` para conocer el estatus actual, los módulos implementados, los contratos existentes y la arquitectura vigente.
   - Si la solicitud involucra persistencia, APIs, modelos de datos o consultas, leer y respetar `DesarrolloDB.md` (**PostgreSQL + PostgREST**).
   - Si la solicitud involucra creación o modificación de pantallas, modales o widgets, leer y aplicar estrictamente `.agents/rules/parametros-diseno.md`.
2. **Al finalizar una tarea (tras aprobación de QA)**:
   - Actualizar el estatus del módulo afectado en la sección correspondiente de este archivo.
   - Registrar una nueva fila en la **Bitácora de Evolución (Changelog)** (Sección 7).
   - Si hubo cambios de base de datos o contratos PostgREST, actualizar también `DesarrolloDB.md`.

---

## 2. Resumen Ejecutivo y Dominio de Negocio

- **Nombre del Proyecto**: **El Mercadito** (paquete Flutter: `app_mercadito`).
- **Naturaleza**: Marketplace agrocomercial B2B/B2C orientado a República Dominicana y LatAm (moneda principal `RD$` / `$`).
- **Roles de Usuario (`UserSession.selectedRole`)**:
  - **Comprador (`comprador`)**: Identificador estándar `BUY-00000001` (`UserSession.formatUserId`). Compra al detalle o al por mayor, negocia precios, canjea cupones, sigue proveedores, califica y reporta.
  - **Proveedor / Productor (`proveedor`)**: Identificador estándar `PROV-00000001`. Publica catálogo con grados de calidad, gestiona ofertas relámpago y cupones, define horarios y políticas, verifica comercio (DGII / RNC) y responde reseñas/negociaciones.
- **Estado de Sesión en Memoria**: `UserSession` (`app_mercadito/lib/services/user_session.dart`) gestiona rol activo, onboarding, verificación de mayoría de edad (`>= 18`), horarios semanales (`DaySchedule`), políticas del vendedor y flujo de verificación comercial (`not_submitted` → `pending` → `verified` / `rejected`, con bloqueo de 30 días tras 3 rechazos).

---

## 3. Stack Tecnológico y Dependencias (`app_mercadito/pubspec.yaml`)

- **SDK**: Dart `^3.11.3` / Flutter Material 3 (`useMaterial3: true`).
- **Navegación**: `go_router: ^17.1.0` con `ShellRoute` para las 5 pestañas principales (`CustomBottomNavBar`) y transiciones suaves (`buildSmoothTransitionPage`).
- **Tipografía y Diseño UI**: `google_fonts: ^8.0.2` (`Plus Jakarta Sans` principal, `Manrope` micro-etiquetas/navegación), `shimmer: ^3.0.0`, `lottie: ^3.1.2`, `flutter_svg: ^2.3.0`, `cached_network_image: ^3.4.1`, `smooth_page_indicator: ^2.0.1`, `tutorial_coach_mark: ^1.3.4`.
- **Mapas y Geolocalización**: `flutter_map: ^8.3.2`, `latlong2: ^0.10.1`.
- **Documentos, Cámara y Multimedia**: `pdf: ^3.12.0`, `printing: ^5.14.3`, `image_picker: ^1.2.2`, `exif: ^3.3.0`, `audioplayers: ^6.7.1`, `url_launcher: ^6.3.2`, `scrollable_positioned_list: ^0.3.8`.
- **Calidad y Linting**: `flutter_lints: ^6.0.0`, `flutter_test`.

---

## 4. Arquitectura del Código y Equipo de Agentes

### Estructura en `app_mercadito/`
- `lib/main.dart`: Entrypoint (`AppMercadito`), `ThemeController.init()`, `MaterialApp.router`.
- `lib/router/app_router.dart`: Rutas GoRouter (`initialLocation: '/splash'`).
- `lib/theme/`: `app_theme.dart` (tokens Día/Noche, `ThemeData`) y `theme_controller.dart` (`AppThemePreference.day`, `night`, `automatic` — noche de `19:00` a `05:59:59`).
- `lib/data/`: Estados y catálogos en memoria (`global_state.dart`, `countries_states.dart`, `legal_policies_data.dart`, `privacy_pdf_data.dart`, `terms_pdf_data.dart`).
- `lib/models/`: Modelos de dominio (`coupon_model.dart`, `market_news_model.dart`, `notification_item.dart`, `provider_map_item.dart`, `standard_catalog_product.dart`, `user_report.dart`).
- `lib/repositories/`: Contratos abstractos e implementaciones (`provider_map_repository.dart` con `IProviderMapRepository`).
- `lib/services/`: Servicios de negocio, audio, PDF, verificación y sesión (14 archivos).
- `lib/screens/`: 64 pantallas organizadas por flujo funcional.
- `lib/widgets/`: 23 widgets reutilizables (tarjetas, badges, skeletons, modales, barra de navegación).
- `test/`: 48 archivos de pruebas unitarias y de widgets.

### Flujo Colegiado de Agentes (`.agents/agents/`)
1. **`lead-orchestrator`**: Analiza requerimientos, consulta `MEMORIA_PROYECTO.md`, `DesarrolloDB.md` y `.agents/rules/parametros-diseno.md`, define contratos y coordina las 4 fases.
2. **`backend-core-specialist`**: Implementa modelos inmutables (`copyWith`, `fromJson`/`toJson`), lógica pura, repositorios y documentación/optimización PostgREST en `DesarrolloDB.md` (sin importar `flutter/material.dart` ni `dart:ui`).
3. **`frontend-specialist`**: Construye pantallas y widgets desacoplados cumpliendo `.agents/rules/parametros-diseno.md`, `AppTheme`, responsive (`SafeArea`, `MediaQuery`, `LayoutBuilder`) y los 4 estados de UI (`Loading`, `Success`, `Empty`, `Error`).
4. **`qa-tester`**: Ejecuta `flutter test`, `dart analyze`, valida contratos, parámetros de diseño y actualiza/verifica la aprobación final.

---

## 5. Inventario del Estatus Actual del Proyecto (Módulos Implementados)

| Área Funcional | Pantallas (`lib/screens/`) | Modelos / Servicios / Widgets Clave | Estatus Actual |
| :--- | :--- | :--- | :--- |
| **Autenticación, Seguridad y Onboarding** | `splash_screen.dart`, `login_screen.dart`, `register_screen.dart`, `register_email_verification_screen.dart`, `welcome_screen.dart`, `age_verification_screen.dart`, `select_role_screen.dart`, `buyer_onboarding_screen.dart`, `provider_onboarding_screen.dart`, `forgot_password_screen.dart`, `change_password_screen.dart`, `two_factor_auth_screen.dart`, `sms_verification_screen.dart`, `email_verification_screen.dart`, `authenticator_verification_screen.dart`, `active_devices_screen.dart` | `UserSession`, `countries_states.dart`, `AnimatedErrorField`, `BouncingButton` | Implementado con estado en memoria (`UserSession`). |
| **Feed Principal, Búsqueda y Navegación** | `home_feed_screen.dart`, `search_screen.dart`, `cart_screen.dart`, `providers_screen.dart`, `providers_map_screen.dart`, `chat_list_screen.dart`, `chat_detail_screen.dart` | `CustomBottomNavBar`, `TutorialService`, `IProviderMapRepository` / `ProviderMapRepository`, `ProviderMapItem`, `ProviderMapFilter`, `provider_map_card.dart`, `provider_map_filter_bar.dart`, `provider_map_pin.dart`, `location_selector_modal.dart`, `typing_indicator.dart` | Implementado. `ShellRoute` activo en `/home`, `/cart`, `/search`, `/providers`, `/providers-map`, `/chats`. |
| **Catálogo, Productos y Verificación EXIF** | `product_detail_screen.dart`, `product_management_screen.dart`, `add_product_screen.dart`, `quality_products_screen.dart` | `StandardProductCatalogService`, `StandardCatalogProduct`, `PriceEvaluation` (`cheap`/`fair`/`expensive` ±15% vs referencia), `ImageVerificationService` (cámara + EXIF), `ProductCard`, `quality_info_bottom_sheet.dart` | Implementado con catálogo estándar y validación de frescura de imagen por EXIF/timestamp. |
| **Ofertas Relámpago y Cupones** | `flash_offers_screen.dart`, `flash_offers_manager_screen.dart`, `flash_offer_edit_dialog.dart`, `coupons_screen.dart`, `coupons_manager_screen.dart` | `globalFlashOffers` + timer global (`global_state.dart`), `CouponsService`, `Coupon`, `CouponBenefit`, `CouponRule`, `CouponTarget`, `CouponAnalytics`, `CouponRedemptionHistory`, `CreateCouponWizard` (4 pasos), `CouponStatsSheet`, `ShareCouponSheet`, `CouponCard`, `AnimatedDiscountBadge` | Implementado. Regla de edición: cupón solo editable si `status == paused && !hasBeenActivated`. |
| **Negociaciones, Pedidos y Facturas PDF** | `negotiations_screen.dart`, `negotiation_detail_screen.dart`, `order_history_screen.dart`, `pdf_preview_screen.dart` | `PdfInvoiceService`, `global_state.dart` | Implementado con generación local de PDF (`pdf` / `printing`). |
| **Análisis de Mercado, Noticias y Tendencias** | `market_analysis_screen.dart`, `market_price_detail_screen.dart`, `dashboard_screen.dart` | `MarketNewsService`, `MarketNewsItem`, `CropTrendPrediction`, `InfiniteMarqueeTicker` | Implementado con noticias, tendencias por cultivo y ticker continuo. |
| **Perfiles, Reputación, DGII/RNC y Comportamiento** | `profile_screen.dart`, `buyer_profile_screen.dart`, `provider_profile_screen.dart`, `my_provider_profile_screen.dart`, `my_reviews_screen.dart`, `direct_profile_review_screen.dart`, `business_verification_screen.dart`, `business_hours_screen.dart`, `seller_policies_screen.dart` | `ReviewsService` (`ProductNegotiationReview` desbloqueada `>= 3 días`, `DirectProfileReview`, `ProviderResponseMetrics` 70% rapidez + 30% tasa), `BuyerBehaviorService` (`BuyerBehaviorProfile`: mediana, pago, índice mayorista, decaimiento $e^{-\lambda t}$), `VerifiedBadge`, `supplier_quick_view_bottom_sheet.dart`, `product_reviews_modal.dart` | Implementado en memoria con cálculos algorítmicos locales. |
| **Favoritos, Seguimiento y Moderación** | `favorites_screen.dart`, `favorite_providers_screen.dart`, `favorite_buyers_screen.dart`, `followed_sellers_screen.dart`, `reports_screen.dart`, `reported_users_screen.dart` | `ReportsService`, `UserReport` (validación máx. 200 caracteres, no auto-reporte), `report_user_bottom_sheet.dart`, `AnimatedFavoriteButton` | Implementado con validación de dominio en `UserReport`. |
| **Gamificación, Notificaciones, Audio y Legal** | `tasks_screen.dart`, `all_tasks_screen.dart`, `notifications_screen.dart`, `alerts_screen.dart`, `help_support_screen.dart`, `legal_policies_screen.dart`, `privacy_screen.dart`, `settings_screen.dart`, `language_screen.dart` | `NotificationService`, `NotificationItem`, `MarketDailySummary`, `SoundService` (8 reproductores dedicados + `SoundFeedbackSplashFactory`), `PrivacyService`, `LegalPdfService`, `help_guide_modal.dart`, `SkeletonScreenLoader` y familia `skeleton_loading.dart` | Implementado. Audio silenciado automáticamente bajo `TestWidgetsFlutterBinding`. |

---

## 6. Estado de Persistencia y Transición a PostgreSQL / PostgREST

- **Situación Actual**: La aplicación funciona actualmente con datos simulados y estado en memoria (`global_state.dart`, `UserSession`, singletons en `lib/services/` y `ProviderMapRepository`). No existe aún un cliente HTTP conectado a una instancia activa de PostgREST en producción dentro de `pubspec.yaml`.
- **Arquitectura Destino**: **PostgreSQL** como motor relacional y **PostgREST** como capa API RESTful automática.
- **Lineamientos de Migración**: Todo nuevo módulo o refactorización hacia persistencia real debe implementar interfaces de repositorio abstractas en `lib/repositories/`, respetar el esquema, índices, políticas RLS y consultas optimizadas definidas en `DesarrolloDB.md`.

---

## 7. Bitácora de Evolución (Changelog)

| Fecha | Solicitud / Módulo | Resumen de Cambios | Archivos Clave | Impacto DB (`DesarrolloDB.md`) | Validación QA |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **2026-11-18** | Infraestructura de Memoria, DB y Diseño | Creación de memoria base del proyecto, guía técnica de base de datos PostgreSQL + PostgREST, regla oficial de parámetros de diseño UI/UX y vinculación en `AGENTS.md` y agentes personalizados. | `MEMORIA_PROYECTO.md`, `DesarrolloDB.md`, `.agents/rules/parametros-diseno.md`, `AGENTS.md`, `.agents/agents/*.md` | Esquema relacional base y estándares PostgREST documentados. | Validación de archivos, tamaño de reglas (< 24 KB) e integridad YAML. |
| **2026-11-18** | Pantalla de Carga (`SplashScreen`) | Eliminación del badge con el enunciado `"Conexión directa productor - comprador"` en `splash_screen.dart` y actualización de aserción en `splash_screen_test.dart`. | `app_mercadito/lib/screens/splash_screen.dart`, `app_mercadito/test/splash_screen_test.dart` | Sin impacto en DB. | `flutter test test/splash_screen_test.dart` (5/5 OK) y `dart analyze` (`No issues found!`). |
| **2026-11-19** | Tutorial en Agregar Producto (`AddProductScreen`) | Implementación del tutorial interactivo de 5 pasos al ingresar por primera vez a Agregar Producto (`showAddProductTutorial` en `TutorialService`, flag `UserSession.hasSeenAddProductTutorial` y `GlobalKey`s + auto-disparo en `AddProductScreen`). | `app_mercadito/lib/services/user_session.dart`, `app_mercadito/lib/services/tutorial_service.dart`, `app_mercadito/lib/screens/add_product_screen.dart`, `app_mercadito/test/tutorial_service_test.dart` | Sin impacto en DB (bandera en memoria `UserSession`; persistencia futura junto al perfil de usuario). | `flutter test test/tutorial_service_test.dart test/standardized_product_catalog_test.dart` (16/16 OK) y `dart analyze` (`No issues found!`). |
| **2026-11-19** | Tutoriales Interactivos en 5 Pantallas Clave (`Tasks`, `Negotiations`, `CouponsManager`, `FlashOffersManager`, `MarketAnalysis`) | Implementación completa de tutoriales interactivos de onboarding por primera vez en 5 pantallas clave: Tareas (Racha, Resumen, Misiones), Negociaciones (Pestañas, Filtros, Gestión de Acuerdos), Gestión de Cupones (Métricas, Filtros, Crear Promoción), Gestión de Ofertas Relámpago (Pestañas, Temporizador/Ofertas Activas, Lanzar Oferta Flash) y Análisis de Mercado (Pestañas, Switcher Detalle/Mayorista, Variación de Precios). Incorporación de flags en `UserSession`, métodos en `TutorialService`, `GlobalKey`s y auto-disparo controlado con cancelación de timers. | `app_mercadito/lib/services/user_session.dart`, `app_mercadito/lib/services/tutorial_service.dart`, `app_mercadito/lib/screens/tasks_screen.dart`, `app_mercadito/lib/screens/negotiations_screen.dart`, `app_mercadito/lib/screens/coupons_manager_screen.dart`, `app_mercadito/lib/screens/flash_offers_manager_screen.dart`, `app_mercadito/lib/screens/market_analysis_screen.dart`, `app_mercadito/test/tutorial_service_test.dart` | Sin impacto en DB relacional (flags en memoria `UserSession`; persistencia proyectada en tabla de perfiles/onboarding según `DesarrolloDB.md`). | `dart analyze` sin errores ni advertencias (`No issues found!`) y suite de tests `test/tutorial_service_test.dart` + regresiones (32/32 tests pasados exitosamente). |
