---
name: Janus Light
colors:
  surface: '#fbf9f4'
  surface-dim: '#dbdad5'
  surface-bright: '#fbf9f4'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f3ee'
  surface-container: '#f0eee9'
  surface-container-high: '#eae8e3'
  surface-container-highest: '#e4e2dd'
  on-surface: '#1b1c19'
  on-surface-variant: '#5b403a'
  inverse-surface: '#30312e'
  inverse-on-surface: '#f2f1ec'
  outline: '#8f7069'
  outline-variant: '#e4beb6'
  surface-tint: '#b72301'
  primary: '#b72301'
  on-primary: '#ffffff'
  primary-container: '#ff5733'
  on-primary-container: '#580c00'
  inverse-primary: '#ffb4a4'
  secondary: '#5f5e5e'
  on-secondary: '#ffffff'
  secondary-container: '#e2dfde'
  on-secondary-container: '#636262'
  tertiary: '#00677c'
  on-tertiary: '#ffffff'
  tertiary-container: '#009fbd'
  on-tertiary-container: '#002f3a'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdad3'
  primary-fixed-dim: '#ffb4a4'
  on-primary-fixed: '#3d0600'
  on-primary-fixed-variant: '#8c1800'
  secondary-fixed: '#e5e2e1'
  secondary-fixed-dim: '#c8c6c5'
  on-secondary-fixed: '#1c1b1b'
  on-secondary-fixed-variant: '#474746'
  tertiary-fixed: '#b0ecff'
  tertiary-fixed-dim: '#60d5f5'
  on-tertiary-fixed: '#001f27'
  on-tertiary-fixed-variant: '#004e5e'
  background: '#fbf9f4'
  on-background: '#1b1c19'
  surface-variant: '#e4e2dd'
typography:
  headline-xl:
    fontFamily: EB Garamond
    fontSize: 48px
    fontWeight: '500'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: EB Garamond
    fontSize: 32px
    fontWeight: '500'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: EB Garamond
    fontSize: 28px
    fontWeight: '500'
    lineHeight: 34px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.05em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  base: 8px
  container-padding: 32px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 64px
---

## Brand & Style

The design system is centered on "Soft Academicism"—a blend of classical intellectualism and modern fluid comfort. It targets a sophisticated audience that values both heritage and a seamless, low-friction digital experience. 

The style is a refined mix of **Minimalism** and **Tactile Fluidity**. By moving away from rigid structures, the interface adopts an organic, approachable feel while maintaining its authoritative edge. The emotional response is one of calm, focused inspiration. Large whitespace and "squishy" interactive surfaces remove the coldness typically associated with traditional serif-based systems.

## Colors

The palette is anchored by **Dawn Orange**, a vibrant yet warm accent used exclusively for primary actions and key highlights. 

- **Primary (Dawn Orange):** Used for CTA buttons, active states, and critical paths.
- **Secondary (Ink):** A deep, off-black for high-contrast typography and iconography.
- **Neutral (Parchment):** A warm, off-white background that reduces eye strain and reinforces the academic theme.
- **Surface (Cloud):** Very subtle, low-opacity greys used for container backgrounds to distinguish them from the main page surface.

## Typography

This design system utilizes a high-contrast typographic pairing to balance tradition with modernity. 

**EB Garamond** is the voice of the system, used for all headlines and editorial moments. It should be set with tight tracking and generous line heights to feel airy and prestigious. 

**Plus Jakarta Sans** provides a friendly, geometric counterpoint for body copy, navigation, and labels. Its soft terminals echo the organic roundness of the UI containers, ensuring legibility and a contemporary feel in functional areas.

## Layout & Spacing

The layout follows a **Fluid Grid** model with an emphasis on "Negative Space as a Luxury." 

- **Desktop:** 12-column grid with wide 64px margins to center the content and provide a focused reading experience.
- **Mobile:** 4-column grid with 16px margins, where cards and containers often span the full width but retain their heavy corner radius to keep the "soft" aesthetic.
- **Rhythm:** Spacing follows an 8px base unit. Component internal padding is intentionally generous (minimum 24px) to prevent the "tight" feeling of legacy SaaS apps.

## Elevation & Depth

Depth is achieved through **Tonal Layers** and **Ambient Shadows** rather than harsh borders. 

- **Surface Tiers:** Backgrounds are `#F9F7F2`. Main containers use a pure white surface or a slightly lighter tint.
- **Shadows:** Use extremely diffused, low-opacity shadows (Opacity: 4-6%) with a subtle color tint from the primary Dawn Orange. This creates a "levitating" effect for cards.
- **Soft Outlines:** Where separation is needed without shadow, use 1px strokes in a very light grey (`#E6E2D9`) to maintain a clean, flat-but-defined appearance.

## Shapes

The shape language is the core differentiator of this design system. It moves away from standard 4px or 8px corners in favor of **Organic Roundness**.

- **Small Components:** Buttons and inputs use a full-pill radius.
- **Medium Components:** Cards and modals use a 24px (1.5rem) radius.
- **Large Components:** Hero sections or main content areas use a 48px (3rem) radius where possible.

Avoid sharp 90-degree angles entirely. Even icons should utilize rounded terminals to match the container language.

## Components

- **Buttons:** Primary buttons are Dawn Orange with white text, utilizing a full pill-shape (round-xl). They feature a subtle hover lift.
- **Input Fields:** Soft-filled backgrounds (a shade darker than the page) with a pill-shaped radius. The focus state uses a 2px Dawn Orange stroke.
- **Cards:** Elevated with the ambient shadow defined in the Elevation section. Corners must be at least 24px. Padding should be 32px to allow the serif headlines room to breathe.
- **Chips/Tags:** Small, pill-shaped containers with low-opacity Dawn Orange backgrounds and dark text.
- **Lists:** Items are separated by generous vertical spacing rather than horizontal lines. Hover states use a subtle color-wash background with rounded corners.
- **Modals:** Centered with a heavy 32px or 48px radius, mimicking the feel of a physical "sheet" or "tablet" resting on the interface.