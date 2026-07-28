# Emerald Harvest Design System

### 1. Overview & Creative North Star
**Creative North Star: The Digital Agrarian**
Emerald Harvest is a design system that bridges the gap between the raw, tactile world of local agriculture and the precision of high-end editorial commerce. It rejects the clinical "tech-white" aesthetic in favor of organic greens, earthy neutrals, and a layout philosophy centered on **Functional Asymmetry**. Elements are not merely placed on a grid; they are curated like a premium farmer's market, using overlapping layers and varying card heights to create a sense of depth and discovery.

### 2. Colors
The palette is rooted in a deep, forest-inspired Primary (`#00462f`) paired with high-contrast functional accents like "Oxblood" Tertiary for price movements and "Sage" Secondary for metadata.

- **The "No-Line" Rule:** Direct sectioning with 1px solid lines is strictly prohibited. Use shifts from `surface` to `surface-container-low` to define the search area, or rely on the natural margins of cards to create visual boundaries.
- **Surface Hierarchy & Nesting:** Use `surface-container-lowest` (#ffffff) for the most interactive elements (Product Cards) to make them "pop" against the `background` (#f7faf5).
- **The "Glass & Gradient" Rule:** Floating elements, such as the "Favorite" button on images, must use a `white/80` backdrop-blur (Glassmorphism) to maintain legibility without obscuring the organic product photography.
- **Signature Textures:** Hero sections utilize the `primary-container` with low-opacity vector overlays (e.g., supply chain wave patterns) to provide a premium, data-driven atmosphere.

### 3. Typography
The system exclusively uses **Plus Jakarta Sans**, a typeface that balances geometric clarity with warm, approachable curves.

- **Display & Headline (1.25rem - 1.125rem):** Used for "Mercadito" branding and section headers. Bold weights (700-800) are required to ground the editorial layout.
- **Body (0.875rem):** The workhorse size for product descriptions and search inputs.
- **Labels & Micro-copy (10px - 8px):** Crucial for the "Market Trends" and "Badges." These use heavy weights (Black/800) and increased letter-spacing to maintain readability at tiny scales.

### 4. Elevation & Depth
Emerald Harvest moves away from Material's "shadow-everything" approach, favoring **Tonal Layering**.

- **The Layering Principle:** Depth is achieved by stacking `surface-container` elements. For example, a search bar sits "inside" the surface, while a product card sits "on top."
- **Ambient Shadows:** Only two shadow levels are permitted:
    - **`shadow-sm`:** Used for product cards and trend cards to provide a subtle "lift" from the background.
    - **`shadow-lg`:** Reserved exclusively for the central FAB and Bottom Navigation to denote global priority.
- **Glassmorphism:** Action icons on top of imagery must use a `backdrop-blur-md` with `white/80` fill rather than a solid color.

### 5. Components
- **Buttons:**
    - **Primary Action:** High-contrast (e.g., White on Primary Container) with all-caps, heavy-weight typography (8px - 10px) and wide letter-spacing.
    - **Icon Buttons:** Circular, with a subtle hover state shift to `neutral-100`.
- **Product Cards:** Rounded corners (0.75rem / `xl`), utilizing a vertical stack: high-quality photography -> metadata (stars/location) -> title -> price.
- **The "Central FAB":** A signature 16x16 (64px) circular button that breaks the top edge of the Bottom Navigation bar, acting as the primary system anchor.
- **Trend Indicators:** Compact cards (w-40) using micro-sparklines to communicate data density without visual clutter.

### 6. Do's and Don'ts
**Do:**
- Use high-quality, high-saturation food photography.
- Maintain generous 1rem (16px) horizontal padding for all main containers.
- Use `primary` (Emerald) for "Verified" badges and key success states.

**Don't:**
- Do not use standard 1px borders for cards; use `outline-variant/20` or simple shadows.
- Do not use generic icons; stick to the "Material Symbols Outlined" set with custom fill/weight settings.
- Avoid perfectly symmetrical layouts; allow horizontal carousels to "peek" off-screen to encourage exploration.