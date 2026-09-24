# GlowQR Design Specification

**Date:** 2026-04-15
**Status:** Approved

---

## Overview

Redesign GlowQR with a dark, neon-accented aesthetic. The app is a simple, single-purpose tool for generating QR codes. The design should be mobile-first, centered, inviting, and free of redundant information.

---

## Design System

### Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Background | `#0a0a0f` | Page background |
| Surface | `#1a1a24` | Cards, inputs |
| Border | `#333333` | Subtle borders |
| Text Primary | `#ffffff` | Headlines |
| Text Secondary | `#666666` | Body text |
| Text Muted | `#444444` | Captions |
| Accent Primary | `#ff00ff` | Neon magenta |
| Accent Gradient | `#ff00ff` → `#ff6600` | Buttons, glows |

### Typography

- **Logo/Brand:** 14px, accent color, sparkle emoji prefix
- **Headline:** 24px, bold, white
- **Subtext:** 14px, muted gray
- **Body:** 14px, regular

### Visual Effects

- **Neon glow:** `box-shadow: 0 0 30px rgba(255,0,255,0.5)`
- **Gradient buttons:** Linear gradient from `#ff00ff` to `#ff6600`
- **Border glow:** Use accent color with glow shadow
- **Border radius:** 8px for cards, 50% for circular QR frames

---

## Layout Structure

### Responsive Strategy

- Mobile-first design
- Content centered with `max-width: ~400px`
- Full-width inputs and buttons on mobile
- Comfortable padding: 20px sides

### Homepage (Hero-First)

**Header:**
- Logo only: "✨ GlowQR"
- No navigation links
- Minimal vertical space

**Content:**
- Tagline: "QR codes in 30 seconds"
- Subtext: "No signup. Just paste & go."

**Form Card:**
- URL input field
- Template selector (horizontal grid of options)
- Generate button

**Template Selector:**
- 2x2 grid of template options
- Each option: small preview + name
- Selected state: neon border glow
- Templates: Classic, Rounded, Circle Frame, Disco Ball

**CTA Button:**
- Gradient background
- Full width
- "Generate Free" text

### Preview Page (QR Focus)

**Header:**
- Logo only (same as homepage)

**QR Display:**
- Large circular QR code (max 250px)
- Neon magenta border with glow effect
- White background inside circle

**Actions:**
- Download PNG button (gradient, full width)
- URL input with copy button

**Link Copy:**
- Read-only input showing share URL
- Copy button with accent color

**Footer:**
- "Create another" link (muted)

---

## Component Inventory

### Logo
```
✨ GlowQR
```
- 14px, accent magenta color
- Sparkle emoji prefix
- Links to homepage

### Text Input
- Background: `#0f0f18`
- Border: 1px `#333`
- Border-radius: 8px
- Padding: 12px 14px
- Focus: accent border color
- Placeholder: muted gray

### Template Card
- Background: `#1a1a24`
- Border: 2px solid `#333`
- Border-radius: 8px
- Contains: template preview + name
- Hover: subtle shadow
- Selected: accent border + glow

### Primary Button
- Background: gradient `#ff00ff` → `#ff6600`
- Text: white, bold
- Padding: 14px
- Border-radius: 8px
- Full width

### QR Code Display
- Circular frame with accent border
- Neon glow shadow
- White background inside
- Max size: 250px

### Copy Link Input
- Background: `#1a1a24`
- Border: 1px `#333`
- Flex layout: input + copy button
- Copy button: accent background

---

## Pages

### `/` - Homepage
- Logo header
- Hero tagline
- URL input
- Template selector
- Generate button

### `/qr_codes/:id/preview` - Preview
- Logo header
- QR code display
- Download button
- Share link with copy
- Create another link

---

## Technical Notes

- Keep views minimal - no unnecessary wrapper divs
- Use Tailwind CSS utility classes
- QR images served via Active Storage
- No authentication in Phase 1
