# GlowQR Rounded Dots Template Design

**Date**: 2026-04-15
**Template Number**: 4
**Name**: Rounded Dots

## Concept

A hybrid template combining Classic's square QR modules with a rounded container frame and scattered dot decoration. The QR itself remains square and scannable, while the frame has rounded corners and decorative dots fill the negative space.

## Technical Specifications

### QR Code
- Uses standard square modules (no rounding on individual modules)
- Module size: 10px (same as Classic)
- QR version: auto-generated based on URL length
- Error correction: Level H (highest)

### Container Frame
- **Shape**: Rounded rectangle
- **Corner radius**: 40px
- **Padding**: 10px between QR and frame edge
- **Border width**: 4px
- **Border color**: Magenta (#ff00ff) with neon glow effect via CSS
- **Background**: White (#ffffff)

### Image Dimensions
- QR: 41 modules × 10px = 410px
- Padding: 20px (10px each side)
- Border: 4px
- Total: ~438px per side (rounded to even number)

### Decorative Dots
- Count: ~400 dots
- Size: 6-8px diameter
- Color: Black (#000000)
- Placement: Random distribution in frame area (outside QR bounds)
- Same random seed for reproducibility

## Implementation

### New File
- `lib/qr_templates/rounded_dots.rb`

### Methods
- `image_size` - Calculate total dimensions
- `module_size` - Return 10px
- `qr_offset` - Center QR within frame
- `corner_radius` - Return 40px
- `draw_white_background` - Draw rounded rectangle with white fill
- `draw_border` - Draw rounded rectangle border in black
- `draw_qr_code` - Draw square QR modules (no rounding)
- `draw_decorative_dots` - Scatter dots in frame area

### Model Updates
- Add template 4 to `QrGeneratorService::TEMPLATES`
- Add "Rounded Dots" to `QrCode#template_name`
- Add `rounded-2xl` class to `QrCode#image_shape_class`
- Neon border: `has_neon_border?` returns true for template 4

## CSS Shape Class
- Preview: `rounded-2xl border-4 border-[#ff00ff] shadow-[0_0_30px_rgba(255,0,255,0.5)]`

## Success Criteria
- QR code is scannable and decodes correctly
- Rounded frame corners visible
- Dots fill frame area without overlapping QR
- Consistent output with same random seed
