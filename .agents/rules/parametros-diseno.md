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
| **Fondo principal** | `#F7F9F8` (`lightBackground`) | `#101815` (`darkBackground`) | `getBackgroundColor(context)` |
| **Fondo secundario** | `#EEF5F1` (`lightSecondaryBackground`) | `#17221E` (`darkSecondaryBackground`) | `getSecondaryBackgroundColor(context)` |
| **Cards estándar** | `#FFFFFF` (`lightCard`) | `#1C2924` (`darkCard`) | `getCardColor(context)` |
| **Card elevada** | `#FFFFFF` (`lightCardElevated`) | `#22332C` (`darkCardElevated`) | `getElevatedCardColor(context)` |
| **Verde principal (Acento)** | `#016042` (`lightPrimary`) | `#67C83B` (`darkPrimary`) | `getPrimaryColor(context)` |
| **Verde fuerte / Botón CTA** | `#016042` (`lightPrimaryCta`) | `#2F7D59` (`darkPrimaryCta`) | `getPrimaryCtaColor(context)` |
| **Verde claro (Contenedor suave)** | `#E5F0EB` (`lightPrimaryLight`) | `#203D31` (`darkPrimaryLight`) | `Theme.of(context).colorScheme.primaryContainer` |
| **Texto principal** | `#20262B` (`lightTextPrimary`) | `#F1F5F3` (`darkTextPrimary`) | `getTextColor(context)` |
| **Texto secundario** | `#697177` (`lightTextSecondary`) | `#AAB8B1` (`darkTextSecondary`) | `getSecondaryTextColor(context)` |
| **Texto terciario** | `#9AA2A7` (`lightTextTertiary`) | `#718078` (`darkTextTertiary`) | `getTertiaryTextColor(context)` |
| **Bordes y divisores** | `#E2E7E4` (`lightBorder`) | `#2B3A34` (`darkBorder`) | `getBorderColor(context)` |
| **Input / Búsqueda** | `#E8F2ED` (`lightInput`) | `#1C3028` (`darkInput`) | `getInputColor(context)` |
| **Iconos normales** | `#52615B` (`lightIcon`) | `#A7B8B0` (`darkIcon`) | `getIconColor(context)` |

### Colores Funcionales y de Estado
- **Éxito (`functionalSuccess`)**: `#67C83B`
- **Oferta (`functionalOffer`)**: `#F5A623`
- **Descuento (`functionalDiscount`)**: `#FFB340`
- **Error**: `#DC2626` / `#E03131` (Día) | `#FF6B6B` (`functionalError`, Noche)
- **Información (`functionalInfo`)**: `#58A6FF`
- **Favorito (`functionalFavorite`)**: `#FF6B81`
- **Verificación Oficial (`VerifiedBadge.verifiedBlue`)**: `#1D9BF0` sobre base circular `#FFFFFF`
- **Alerta / Badge de Chat (`CustomBottomNavBar`)**: `#BD4437` con texto `#FFFFFF`

---

## 4. Etiquetas (Badges) y Choice Chips

### 4.1 Etiquetas de Calidad de Producto
- **Primera Calidad**: Fondo `#DCE9E5` (Noche: `#016042` al 35% alpha) | Texto `#016042` (Noche: `#6EE7B7`).
- **Segunda Calidad**: Fondo `#FFF4E5` (Noche: `#FF9A04` al 25% alpha) | Texto `#FF9A04` (Noche: `#FDBA74`).
- **Tercera Calidad**: Fondo `#FDEDED` (Noche: `#F44336` al 25% alpha) | Texto `#F44336` (Noche: `#FCA5A5`).

### 4.2 Etiquetas de Categoría y Modalidad de Venta
- **Categoría**: Fondo `#EAF2E8` | Texto `#016042` | Borde `#BBD5C7`.
- **Al Detalle**: Fondo `#059669` (Noche: `#047857`) | Texto `#F1F9F7` / `#FFFFFF` | Borde `#059669`.
- **Al Por Mayor**: Fondo `#0369A1` (Noche: `#0284C7`) | Texto `#EDF4F8` / `#FFFFFF` | Borde `#0369A1`.

### 4.3 Choice Chips (Filtros y Selectores)
- **Seleccionado**: Fondo `#016042` | Texto e Icono `#FFFFFF` | Borde `#016042`.
- **No seleccionado**: Fondo `#F1F4F0` | Texto e Icono `#737373` | Borde `#CCDFD9` (en Modo Noche adaptar superficie al contenedor oscuro con borde `darkBorder`).

---

## 5. Diseño de Botones y Microinteracciones

- **Botón Primario (`ElevatedButton`)**:
  - Altura mínima: `48px` (`minimumSize: const Size(0, 48)`).
  - Borde redondeado: `BorderRadius.circular(8)` (o `12` en CTAs destacados de tarjetas/modales).
  - Fondo: `#016042` (`lightPrimaryCta`) en Día / `#2F7D59` (`darkPrimaryCta`) en Noche.
  - Texto: `#FFFFFF`, `fontSize: 16`, `FontWeight.bold`.
  - Elevación: `2`, sombra `lightPrimary.withValues(alpha: 0.3)` (Día) / `Colors.black.withValues(alpha: 0.3)` (Noche).
- **Botón Secundario (`OutlinedButton`)**:
  - Altura mínima: `48px`, `BorderRadius.circular(8)`.
  - Fondo: `#FFFFFF` (Día) / `#1C2924` (`darkCard` en Noche).
  - Borde: `1px` `lightBorder` (`#E2E7E4`) / `darkBorder` (`#2B3A34`).
  - Texto: `TextPrimary`, `fontSize: 16`, `FontWeight.w600`.
- **Feedback Táctil y Sonoro Obligatorio**:
  - Envolver botones personalizados, tarjetas clicables e iconos accionables en `BouncingButton` (`lib/widgets/bouncing_button.dart`), que aplica escala `0.95` en `110ms`, háptica `HapticFeedback.selectionClick()` y `SoundService.playButtonClick()`.
  - Los botones nativos Material heredan automáticamente `SoundFeedbackSplashFactory` desde `AppTheme`.

---

## 6. Inputs, Formularios y Validación de Errores

- **Campos de Texto (`InputDecorationTheme`)**:
  - `filled: true`, `fillColor`: `#E8F2ED` (Día) / `#1C3028` (Noche).
  - `contentPadding`: `EdgeInsets.symmetric(horizontal: 16, vertical: 14)`.
  - Bordes (`border` / `enabledBorder`): `OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: border))`.
  - Foco (`focusedBorder`): `borderSide: BorderSide(color: primary, width: 2)`.
- **Validación Visual y Sonora (`AnimatedErrorField`)**:
  - Envolver campos con validación obligatoria en `AnimatedErrorField` (`lib/widgets/animated_error_field.dart`, `borderRadius: 12.0`).
  - Al producirse error: vibración horizontal senoidal (`400ms`), borde rojo (`#E03131` Día / `#FF6B6B` Noche, `1.6px`), mensaje inferior con `Icons.error_outline_rounded`, háptica y `SoundService.playError()`.

---

## 7. Tarjetas, Imágenes, Estados de UI y Navegación

- **Tarjetas y Separación en Modo Noche**:
  - Tarjetas estándar: `elevation: 0`, `borderRadius: 12–16`, borde `1px` con `AppTheme.getBorderColor(context)`.
  - En Modo Noche usar `darkCard` (`#1C2924`) sobre `darkBackground` (`#101815`) para lograr separación limpia sin sombras fuertes.
  - **Regla estricta de imágenes**: **Nunca oscurecer** ni aplicar overlays oscuros agresivos sobre las fotografías de productos en Modo Noche.
  - Contenedores de formularios centrados (Login, Registro, Verificación): `BoxConstraints(maxWidth: 448)`, `borderRadius: 12`, sombra `blurRadius: 20, offset: Offset(0, 10)`.
- **Estados de UI y Skeletons**:
  - Toda pantalla debe contemplar explícitamente los **4 estados**: `Loading`, `Success`, `Empty` y `Error` (con acción de reintento).
  - Usar `SkeletonScreenLoader` y los componentes de `lib/widgets/skeleton_loading.dart` (`SkeletonShimmer`, `SkeletonProductCard`, `SkeletonSearchProductCard`, `SkeletonListTile`, `SkeletonFormView`, etc.) durante el estado `Loading`.
- **Navegación y Responsive**:
  - Registrar rutas en `app_mercadito/lib/router/app_router.dart` usando `buildSmoothTransitionPage` (`260ms`, `FadeTransition` + `SlideTransition` suave).
  - Usar `SafeArea`, `MediaQuery` y `LayoutBuilder` para prevenir cualquier `RenderFlex overflow`.
  - Usar `.withValues(alpha: ...)` en lugar de `.withOpacity(...)` (deprecado en Flutter moderno).
