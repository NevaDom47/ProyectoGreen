---
name: Emerald Harvest
colors:
  surface: '#f8f9ff'
  surface-dim: '#d1dbec'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eef4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dfe9fa'
  surface-container-highest: '#d9e3f4'
  on-surface: '#121c28'
  on-surface-variant: '#3f4944'
  inverse-surface: '#27313e'
  inverse-on-surface: '#eaf1ff'
  outline: '#6f7973'
  outline-variant: '#bec9c2'
  surface-tint: '#1b6b51'
  primary: '#004532'
  on-primary: '#ffffff'
  primary-container: '#065f46'
  on-primary-container: '#8bd6b7'
  inverse-primary: '#8bd6b6'
  secondary: '#904d00'
  on-secondary: '#ffffff'
  secondary-container: '#fe932c'
  on-secondary-container: '#663500'
  tertiary: '#00415f'
  on-tertiary: '#ffffff'
  tertiary-container: '#005980'
  on-tertiary-container: '#8bcfff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#a6f2d1'
  primary-fixed-dim: '#8bd6b6'
  on-primary-fixed: '#002116'
  on-primary-fixed-variant: '#00513b'
  secondary-fixed: '#ffdcc3'
  secondary-fixed-dim: '#ffb77d'
  on-secondary-fixed: '#2f1500'
  on-secondary-fixed-variant: '#6e3900'
  tertiary-fixed: '#c9e6ff'
  tertiary-fixed-dim: '#89ceff'
  on-tertiary-fixed: '#001e2f'
  on-tertiary-fixed-variant: '#004c6e'
  background: '#f8f9ff'
  on-background: '#121c28'
  surface-variant: '#d9e3f4'
typography:
  display-lg:
    fontFamily: Manrope
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-sm:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  data-mono:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 16px
  margin-mobile: 16px
  margin-desktop: 48px
---

## Brand & Style
The design system is built for the precision and organic nature of modern agriculture. It balances a **Corporate/Modern** foundation with **Tactile** elements to evoke reliability and growth. The target audience includes farm managers and agronomists who require high-density information layouts that remain legible under varying field conditions.

The aesthetic leans into "Technical Organicism"—clean, systematic structures paired with soft, natural tones. It utilizes high-quality whitespace to reduce cognitive load during complex inventory management tasks, ensuring a professional and trustworthy emotional response.

## Colors
The palette is rooted in an "Emerald" primary green (#065F46) representing growth and health, and a "Harvest" amber secondary (#D97706) for action and alerts. 

For inventory management, a specific `edit_mode_bg` is introduced to provide a subtle visual anchor when a record is being modified. Neutral tones are cool-greys to maintain a technical feel. Color contrast adheres to WCAG AA standards to ensure legibility in outdoor environments.

## Typography
This design system uses **Manrope** for headlines to provide a modern, balanced look. **Inter** is used for body text due to its exceptional legibility in data-heavy interfaces. 

**JetBrains Mono** is utilized for functional labels and SKU/Inventory codes, signaling to the user that these are technical, precise data points. On mobile devices, `display-lg` scales down to 32px to ensure layout integrity.

## Layout & Spacing
The system employs a **Fluid Grid** based on a 4px baseline shift. This allows for the high-density information density required for agricultural logs.

Desktop layouts use a 12-column grid with 24px gutters. On mobile, the grid collapses to 4 columns with 16px margins. Inventory tables and forms should use the `md` (16px) spacing for internal padding to maintain a comfortable tap target while maximizing data visibility.

## Elevation & Depth
Depth is communicated through **Tonal Layers** and soft **Ambient Shadows**. 

- **Surface 0 (Base):** Light grey or white background.
- **Surface 1 (Cards/Tables):** White with a 1px `slate-200` border and a very soft, 4% opacity shadow.
- **Surface 2 (Active Edit):** When a row or field is in an active edit state, it lifts slightly with a 12% opacity shadow and a subtle green-tinted glow.
- **Overlays (Modals/Popovers):** Higher elevation with a 20% opacity shadow to focus attention on critical inventory adjustments.

## Shapes
The design system uses a **Rounded** (level 2) strategy. Base components (inputs, buttons) utilize a 0.5rem (8px) radius. Larger containers like inventory cards use `rounded-lg` (1rem). 

This soft geometry offsets the "coldness" of technical data, making the software feel more approachable and modern.

## Components

### Interactive Form Controls
- **Input Fields:** Use a 1px solid border. In focus state, apply a 2px `focus_ring` offset. 
- **Inventory Steppers:** For quantity adjustments, use large, tactile "+" and "-" buttons (minimum 44x44px tap target) flanking the input.
- **Complex Selectors:** Use searchable dropdowns for crop varieties or chemical types, featuring the `data-mono` font for SKU identifiers within the list.

### Edit States
- **Inline Editing:** When a field is toggled to edit mode, the background transitions to `edit_mode_bg`. The border color changes to the primary emerald.
- **Dirty State:** Changed but unsaved values are marked with a secondary amber "dot" indicator to the left of the label.

### Lists & Tables
- **Zebra Striping:** Use for large inventory sets to maintain row-tracking.
- **Status Chips:** Use high-contrast backgrounds with white text (e.g., "In Stock" in Success, "Low Stock" in Warning).

### Action Buttons
- **Primary Action:** Solid Emerald background, white text.
- **Cancel/Ghost:** Transparent background, `neutral_color_hex` text and border.
- **Destructive:** Solid Error red for "Delete Item" or "Discard Changes."