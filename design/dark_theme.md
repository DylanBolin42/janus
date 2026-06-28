---
name: Liminal Dawn
colors:
  surface: '#111415'
  surface-dim: '#111415'
  surface-bright: '#373a3b'
  surface-container-lowest: '#0c0f10'
  surface-container-low: '#191c1d'
  surface-container: '#1d2021'
  surface-container-high: '#282a2b'
  surface-container-highest: '#323536'
  on-surface: '#e1e3e4'
  on-surface-variant: '#e0c0b0'
  inverse-surface: '#e1e3e4'
  inverse-on-surface: '#2e3132'
  outline: '#a78b7c'
  outline-variant: '#584236'
  surface-tint: '#ffb68e'
  primary: '#ffb68e'
  on-primary: '#542200'
  primary-container: '#ff770f'
  on-primary-container: '#5c2600'
  inverse-primary: '#9c4500'
  secondary: '#c0c7d5'
  on-secondary: '#2a313c'
  secondary-container: '#454c58'
  on-secondary-container: '#b5bcca'
  tertiary: '#bdc7dc'
  on-tertiary: '#273141'
  tertiary-container: '#959fb4'
  on-tertiary-container: '#2c3647'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffdbca'
  primary-fixed-dim: '#ffb68e'
  on-primary-fixed: '#331200'
  on-primary-fixed-variant: '#773300'
  secondary-fixed: '#dce3f2'
  secondary-fixed-dim: '#c0c7d5'
  on-secondary-fixed: '#151c27'
  on-secondary-fixed-variant: '#404753'
  tertiary-fixed: '#d9e3f9'
  tertiary-fixed-dim: '#bdc7dc'
  on-tertiary-fixed: '#121c2c'
  on-tertiary-fixed-variant: '#3d4759'
  background: '#111415'
  on-background: '#e1e3e4'
  surface-variant: '#323536'
typography:
  display-lg:
    fontFamily: EB Garamond
    fontSize: 64px
    fontWeight: '500'
    lineHeight: 72px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: EB Garamond
    fontSize: 40px
    fontWeight: '500'
    lineHeight: 48px
  headline-lg-mobile:
    fontFamily: EB Garamond
    fontSize: 32px
    fontWeight: '500'
    lineHeight: 40px
  title-md:
    fontFamily: EB Garamond
    fontSize: 24px
    fontWeight: '400'
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
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  unit: 8px
  container-max: 1280px
  gutter: 24px
  margin-desktop: 64px
  margin-mobile: 20px
---

## Brand & Style
The design system inhabits a "liminal" space—the evocative threshold between transitions. It targets an audience that values quiet luxury, intellectual depth, and fluid interaction. The aesthetic is a sophisticated blend of **Minimalism** and **Glassmorphism**, leaning into the atmospheric quality of a digital dawn. 

The emotional response should be one of calm focus and rhythmic elegance. High-end editorial sensibilities are met with futuristic, liquid-like interfaces. By utilizing generous whitespace and translucent layering, the system creates a sense of physical depth without the weight of traditional skeuomorphism.

## Colors
The palette is anchored by **Deep Space Blue (#1E2530)**, providing a vast, stable foundation. The primary accent, **Dawn Orange (#FF770F)**, cuts through the dark background with high energy, used sparingly for critical actions and brand moments to ensure it retains its "liminal" glow.

For the dark theme, surface colors are derived from Deep Space Blue with shifting opacities rather than flat greys, maintaining a monochromatic depth. Contrast is strictly managed to ensure the orange remains vibrant but legible. Text primarily uses an off-white to reduce ocular strain against the deep blue.

## Typography
The system employs **EB Garamond** for all expressive and editorial roles. Its classical serifs provide the "elegant" counterweight to the modern UI. Large display sizes should use tighter letter spacing to emphasize their sculptural quality.

**Inter** serves as the functional workhorse for body copy and UI labels. This pairing ensures that while the brand feels literary and timeless, the interface remains highly legible and systematic. Small labels should be set in uppercase with slight tracking to improve scannability against dark surfaces.

## Layout & Spacing
This design system utilizes a **fluid grid** with an emphasis on asymmetric breathing room. A 12-column system governs desktop layouts, while mobile transitions to a single-column flow with generous vertical padding.

Spacing is strictly based on an 8px scale. To reinforce the "liminal" feel, avoid overcrowding; use the `margin-desktop` tokens to push content away from edges, creating a floating, cinematic frame. Section vertical spacing should be expansive to allow the EB Garamond headlines to "breathe."

## Elevation & Depth
Depth is communicated through **Glassmorphism** and tonal layering. Rather than traditional black shadows, elevation is achieved by increasing the lightness of the surface container and adding a subtle **Backdrop Blur (12px - 20px)**.

Higher elevation levels are signified by a thin, 1px inner border (stroke) using a low-opacity version of the neutral color, simulating a glass edge catching the light. Dawn Orange should never be used on elevated surfaces except for active states, where it appears as a soft glow from beneath the element.

## Shapes
The shape language is defined by **maximum fluidity**. With a `ROUND_FULL` approach, the design system uses large radii to soften the technical nature of the Deep Space Blue palette. 

Small components (buttons, tags) are fully pill-shaped. Large containers (cards, modals) utilize the `rounded-xl` token (3rem/48px) to create a "squircle-like" organic feel. This extreme roundness is the primary driver of the system's friendly yet sophisticated character.

## Components
- **Buttons**: Primary buttons are solid Dawn Orange with white Inter text. Secondary buttons use a glass-morphic background (semi-transparent Deep Space Blue) with a white border. All buttons are fully pill-shaped.
- **Input Fields**: Ghost-style inputs with a subtle bottom border or a very soft, translucent fill. Focus states trigger a Dawn Orange glow and a slight increase in backdrop blur.
- **Cards**: Cards must use high roundedness (3rem) and a background blur. Avoid heavy shadows; use a 1px border at 10% opacity for definition.
- **Chips/Tags**: Small, fully rounded elements. For active states, use Dawn Orange with a subtle pulse animation to suggest the "liminal" energy.
- **Lists**: Items are separated by generous padding rather than lines. Hover states should use a soft, rounded selection highlight that transitions smoothly between items.