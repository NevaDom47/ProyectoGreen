# Regla Oficial de Parámetros de Diseño UI/UX — El Mercadito (`app_mercadito`)

> **Alcance**: Obligatoria para `frontend-specialist`, `lead-orchestrator` y `qa-tester` en toda pantalla, modal, bottom sheet o widget nuevo o modificado.
> **Fuente de verdad en código**: `app_mercadito/lib/theme/app_theme.dart` y `app_mercadito/lib/theme/theme_controller.dart`.

---

## 1. Principios de Identidad Visual
- **Lenguaje de diseño**: Material 3 (`useMaterial3: true`), estética agrocomercial limpia ("Emerald Harvest"), alto contraste, soporte dual nativo **Modo Día** (`06:00–18:59`) y **Modo Noche** (`19:00–05:59`, gestionado por `ThemeController`).
- **Prohibido usar colores fijos sin adaptar al brillo activo**: Consumir siempre los helpers estáticos de `AppTheme` (`AppTheme.getBackgroundColor(context)`, `AppTheme.getCardColor(context)`, etc.) o `Theme.of(context)`.

---

## 2. Tipografía Oficial (`google_fonts`)

- **Fuente Principal**: **`Plus Jakarta Sans`** (`GoogleFonts.plusJakartaSans` / `GoogleFonts.plusJakartaSansTextTheme()`).
  - `displayLarge` / `titleLarge`: `FontWeight.bold` (`w700`), color `TextPrimary`.
  - `titleMedium`: `FontWeight.w600`, color `TextPrimary`.
  - `bodyLarge`: `FontWeight.w400`, color `TextPrimary`.
  - `bodyMedium`: `FontWeight.w400`, color `TextSecondary`.
  - `bodySmall`: `FontWeight.w400`, color `TextTertiary`.
- **Fuente Secundaria (Micro-labels / Navegación)**: **`Manrope`**, usada en etiquetas de navegación y badges compactos (`CustomBottomNavBar`: `10.5px` `FontWeight.w800` activo / `9.5px` `FontWeight.w600` inactivo, `letterSpacing: -0.2`).

---

## 3. Paleta de Colores Dual (Modo Día y Modo Noche)

| Token / Elemento | Modo Día (`AppTheme`) | Modo Noche (`AppTheme`) | Helper Dinámico en `AppTheme` |
| :--- | :--- | :--- | :--- |
| **Fondo principal** | `#F7F9F8` (`lightBackground`) | `#0B0E11` (`darkBackground`) | `getBackgroundColor(context)` |
| **Fondo secundario / Surface 1** | `#EEF5F1` (`lightSecondaryBackground`) | `#14181F` (`darkSecondaryBackground`) | `getSecondaryBackgroundColor(context)` |
| **Cards estándar (Surface 1)** | `#FFFFFF` (`lightCard`) | `#14181F` (`darkCard`) | `getCardColor(context)` |
| **Card elevada / Drawer / Nav (Surface 2)** | `#FFFFFF` (`lightCardElevated`) | `#1C222B` (`darkCardElevated`) | `getElevatedCardColor(context)` |
| **Verde principal (Acento Esmeralda)** | `#016042` (`lightPrimary`) | `#10B981` (`darkPrimary`) | `getPrimaryColor(context)` |
| **Verde fuerte / Botón CTA** | `#016042` (`lightPrimaryCta`) | `#10B981` (`darkPrimaryCta`) | `getPrimaryCtaColor(context)` |
| **Verde claro / Contenedor activo** | `#E5F0EB` (`lightPrimaryLight`) | `rgba(16, 185, 129, 0.14)` (`darkPrimaryLight`) | `Theme.of(context).colorScheme.primaryContainer` |
| **Texto principal** | `#20262B` (`lightTextPrimary`) | `#F3F4F6` (`darkTextPrimary`) | `getTextColor(context)` |
| **Texto secundario** | `#697177` (`lightTextSecondary`) | `#9CA3AF` (`darkTextSecondary`) | `getSecondaryTextColor(context)` |
| **Texto terciario / Placeholder / SKU** | `#9AA2A7` (`lightTextTertiary`) | `#6B7280` (`darkTextTertiary`) | `getTertiaryTextColor(context)` |
| **Bordes sutiles (1px)** | `#E2E7E4` (`lightBorder`) | `#262D38` (`darkBorder`) | `getBorderColor(context)` |
| **Bordes secundarios / inactivos** | `#CCDFD9` | `#2E3744` (`darkBorderSubtle`) | `Theme.of(context).colorScheme.outlineVariant` |
| **Input / Búsqueda** | `#E8F2ED` (`lightInput`) | `#14181F` (`darkInput`) | `getInputColor(context)` |
| **Iconos normales** | `#52615B` (`lightIcon`) | `#9CA3AF` (`darkIcon`) | `getIconColor(context)` |

### Colores Funcionales y de Estado
- **Éxito / Variaciones Positivas (+)**: `#34D399` (Noche) / `#67C83B` (Día)
- **Oferta (`functionalOffer`)**: `#F5A623`
- **Descuento (`functionalDiscount`)**: `#FFB340`
- **Error / Variaciones Negativas (-) / Badges**: `#DC2626` / `#E03131` (Día) | `#EF4444` (`functionalError`, Noche con texto blanco)
- **Información (`functionalInfo`)**: `#58A6FF`
- **Favorito (`functionalFavorite`)**: `#FF6B81`
- **Verificación Oficial (`VerifiedBadge.verifiedBlue`)**: `#1D9BF0` sobre base circular `#FFFFFF`
- **Alerta / Badge de Chat (`CustomBottomNavBar`)**: `#EF4444` con texto `#FFFFFF` (Noche) / `#BD4437` (Día)

---

## 4. Etiquetas (Badges) y Choice Chips

### 4.1 Etiquetas de Calidad de Producto
- **Primera Calidad**: Fondo `#DCE9E5` (Noche: `rgba(16, 185, 129, 0.14)`) | Texto `#016042` (Noche: `#34D399`).
- **Segunda Calidad**: Fondo `#FFF4E5` (Noche: `#FF9A04` al 25% alpha) | Texto `#FF9A04` (Noche: `#FDBA74`).
- **Tercera Calidad**: Fondo `#FDEDED` (Noche: `#EF4444` al 25% alpha) | Texto `#F44336` (Noche: `#FCA5A5`).

### 4.2 Etiquetas de Categoría y Modalidad de Venta
- **Categoría**: Fondo `#EAF2E8` | Texto `#016042` | Borde `#BBD5C7`.
- **Al Detalle (Activo)**: Fondo `rgba(16, 185, 129, 0.14)` (Noche) | Borde `#10B981` (30% opacidad) | Texto `#34D399`. (Día: Fondo `#059669` | Texto `#FFFFFF`).
- **Al Por Mayor (Inactivo)**: Fondo `#1C222B` (Noche) | Borde `#2E3744` | Texto `#D1D5DB`. (Día: Fondo `#0369A1` | Texto `#FFFFFF`).
- **Banner Análisis de Mercado**: Degradado oscuro sutil de `#142822` a `#14181F` con borde `#1F3D33`, título en `#F3F4F6`, texto en `#9CA3AF` y botón CTA en `#10B981`.

### 4.3 Choice Chips (Filtros y Selectores)
- **Activo**: Fondo `rgba(16, 185, 129, 0.14)` | Borde `#10B981` (30% opacidad) | Texto `#34D399` (Noche). Fondo `#016042` | Texto e Icono `#FFFFFF` (Día).
- **Inactivo**: Fondo `#1C222B` | Borde `#2E3744` | Texto `#D1D5DB` (Noche). Fondo `#F1F4F0` | Borde `#CCDFD9` (Día).

---

## 5. Diseño de Botones y Microinteracciones

- **Botón Primario (`ElevatedButton`)** ("Proveedores", "Agregar al carrito", "Crear cuenta"):
  - Altura mínima: `48px` (`minimumSize: const Size(0, 48)`).
  - Borde redondeado: `BorderRadius.circular(8)` (o `12` en CTAs destacados de tarjetas/modales).
  - Fondo: `#016042` (`lightPrimaryCta`) en Día / `#10B981` (`darkPrimary`) en Noche.
  - Texto: `#FFFFFF` (Día) / `#06281E` o `#FFFFFF` en negrita SemiBold (ratio > 4.5:1) en Noche.
  - Elevación: `2` (Día) / `0` en Noche (evita sombras pesadas y neón excesivo).
- **Botón Secundario (`OutlinedButton`)**:
  - Altura mínima: `48px`, `BorderRadius.circular(8)`.
  - Fondo: `#FFFFFF` (Día) / `#1C222B` (Noche).
  - Borde: `1px` `lightBorder` (`#E2E7E4`) / `darkBorderSubtle` (`#2E3744`).
  - Texto: `TextPrimary` (Día) / `#D1D5DB` (Noche), `fontSize: 16`, `FontWeight.w600`.
- **Feedback Táctil y Sonoro Obligatorio**:
  - Envolver botones personalizados, tarjetas clicables e iconos accionables en `BouncingButton` (`lib/widgets/bouncing_button.dart`), que aplica escala `0.95` en `110ms`, háptica `HapticFeedback.selectionClick()` y `SoundService.playButtonClick()`.
  - Los botones nativos Material heredan automáticamente `SoundFeedbackSplashFactory` desde `AppTheme`.

---

## 6. Inputs, Formularios y Validación de Errores

- **Campos de Texto (`InputDecorationTheme`)**:
  - `filled: true`, `fillColor`: `#E8F2ED` (Día) / `#14181F` (Noche).
  - `contentPadding`: `EdgeInsets.symmetric(horizontal: 16, vertical: 14)`.
  - Bordes (`border` / `enabledBorder`): `OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: border, width: 1))`. Borde Noche: `#262D38`.
  - Foco (`focusedBorder`): `borderSide: BorderSide(color: isDark ? Color(0xFF10B981) : primary, width: 1.5)`.
  - Icono izquierdo: `#52615B` (Día) / `#6B7280` (Noche).
  - Hint / Placeholder: `#9AA2A7` (Día) / `#6B7280` (Noche).
- **Validación Visual y Sonora (`AnimatedErrorField`)**:
  - Envolver campos con validación obligatoria en `AnimatedErrorField` (`lib/widgets/animated_error_field.dart`, `borderRadius: 12.0`).
  - Al producirse error: vibración horizontal senoidal (`400ms`), borde rojo (`#E03131` Día / `#EF4444` Noche, `1.6px`), mensaje inferior con `Icons.error_outline_rounded`, háptica y `SoundService.playError()`.

---

## 7. Tarjetas, Imágenes, Estados de UI y Navegación

- **Tarjetas y Separación en Modo Noche**:
  - Tarjetas estándar (Surface 1): `elevation: 0`, `borderRadius: 12–16`, color `#14181F`, borde sutil `1px solid #262D38`.
  - Elevación por color sin sombras pesadas sobre el fondo `#0B0E11`.
  - Drawer, Bottom Bar y Modales (Surface 2): color `#1C222B` con borde superior/lateral `1px solid #262D38`.
  - **Regla estricta de imágenes**: **Nunca oscurecer** ni aplicar overlays oscuros agresivos sobre las fotografías de productos en Modo Noche.
  - Contenedores de formularios centrados (Login, Registro, Verificación): `BoxConstraints(maxWidth: 448)`, `borderRadius: 12`, sombra `blurRadius: 20, offset: Offset(0, 10)`.
- **Estados de UI y Skeletons**:
  - Toda pantalla debe contemplar explícitamente los **4 estados**: `Loading`, `Success`, `Empty` y `Error` (con acción de reintento).
  - Usar `SkeletonScreenLoader` y los componentes de `lib/widgets/skeleton_loading.dart` (`SkeletonShimmer`, `SkeletonProductCard`, `SkeletonSearchProductCard`, `SkeletonListTile`, `SkeletonFormView`, etc.) durante el estado `Loading`.
- **Navegación y Responsive**:
  - Registrar rutas en `app_mercadito/lib/router/app_router.dart` usando `buildSmoothTransitionPage` (`260ms`, `FadeTransition` + `SlideTransition` suave).
  - Usar `SafeArea`, `MediaQuery` y `LayoutBuilder` para prevenir cualquier `RenderFlex overflow`.
  - Usar `.withValues(alpha: ...)` en lugar de `.withOpacity(...)` (deprecado en Flutter moderno).
