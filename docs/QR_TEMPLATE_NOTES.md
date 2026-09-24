# QR Template Development Notes

## What We Learned

### 1. QR Code Generation with ChunkyPNG

**The QR code matrix comes from RQRCode gem:**
```ruby
qrcode = RQRCode::QRCode.new(url, level: :h, size: 6)
qrcode.modules  # 2D array of booleans (true = dark module)
```

**Iterate over modules:**
```ruby
qrcode.modules.each_with_index do |row, y|
  row.each_with_index do |is_dark, x|
    # Draw module at (x, y)
  end
end
```

### 2. Image Dimensions

- QR version determines module count (version 6 = 41x41 modules)
- Module size multiplied by module count = QR pixel size
- Add padding for container designs

```
Image Size = (Modules × Module Size) + (Padding × 2) + (Border × 2)
```

### 3. ChunkyPNG Color Handling

**Avoid using named colors with transparency:**
```ruby
# Bad - creates grayscale+alpha which doesn't display correctly
png = ChunkyPNG::Image.new(size, size, ChunkyPNG::Color::TRANSPARENT)
png[x, y] = ChunkyPNG::Color.rgba(255, 255, 255, 255)

# Good - use ChunkyPNG::Color("white") for solid colors
png = ChunkyPNG::Image.new(size, size, ChunkyPNG::Color::WHITE)
png[x, y] = ChunkyPNG::Color("black")
```

**ChunkyPNG defaults to grayscale encoding**, even when you use RGBA colors. The grayscale+alpha format (color type 4) doesn't display correctly in many image viewers.

### 4. Creating True RGBA PNGs

**Use ImageMagick for proper RGBA output:**

```ruby
def render_png
  # Generate base QR with ChunkyPNG (solid white background)
  png = ChunkyPNG::Image.new(image_size, image_size, ChunkyPNG::Color::WHITE)
  draw_qr_code(png)

  # Use ImageMagick to create proper RGBA with transparency
  convert_to_rgba(png.to_s)
end

def convert_to_rgba(png_data)
  Tempfile.create(["qr", ".png"], binmode: true) do |input|
    Tempfile.create(["qr", ".png"], binmode: true) do |output|
      Tempfile.create(["qr", ".png"], binmode: true) do |mask|
        File.binwrite(input.path, png_data)
        create_transparency_mask(mask.path)
        apply_mask(input.path, mask.path, output.path)
        File.binread(output.path)
      end
    end
  end
end
```

**The ImageMagick conversion process:**
1. Create grayscale base with ChunkyPNG
2. Create a mask image (white where transparent, black where opaque)
3. Apply mask to create proper RGBA

```bash
# Step 1: Convert input to RGB
magick input.png -alpha off -colorspace RGB temp_rgb.png

# Step 2: Convert mask to RGBA
magick mask.png -alpha on temp_mask_rgba.png

# Step 3: Apply mask
magick temp_rgb.png temp_mask_rgba.png -compose CopyOpacity -composite \
  -colorspace sRGB output.png
```

### 5. Random Number Generation

**Never use `srand` globally:**
```ruby
# Bad - pollutes global random state
srand(42)
rand(100)

# Good - use local Random instance
rng = Random.new(42)
rng.rand(100)
```

### 6. Template File Location

**Use `lib/qr_templates/` not `app/templates/`:**

Rails 8 has autoloading that conflicts with `app/templates/`. Put custom templates in `lib/qr_templates/` and require them explicitly:

```ruby
require "qr_templates"

class QrGeneratorService
  TEMPLATES = {
    1 => QrTemplates::Classic,
    2 => QrTemplates::Rounded,
    # ...
  }.freeze
end
```

### 7. Template Structure

Each template should:
1. Inherit from `QrTemplates::Base`
2. Implement `render_png` returning PNG bytes
3. Use module_size, qr_size, image_size helpers
4. Be registered in `QrGeneratorService::TEMPLATES`
5. Have model methods: `template_name`, `image_shape_class`, `has_neon_border?`

### 8. Debugging PNG Issues

**Check PNG color type:**
```bash
file image.png
# 8-bit gray+alpha = grayscale with alpha (problematic)
# 8-bit/color RGBA = true RGBA (correct)
```

**Check pixel values:**
```ruby
require 'chunky_png'
png = ChunkyPNG::Image.from_file('image.png')
puts ChunkyPNG::Color::WHITE  # 4294967295
puts ChunkyPNG::Color::BLACK  # 255
puts ChunkyPNG::Color::TRANSPARENT  # 0
```

### 9. Circle/Drawing Calculations

**Circle boundary:**
```ruby
def is_in_circle?(x, y, center_x, center_y, radius)
  dx = x - center_x
  dy = y - center_y
  dx * dx + dy * dy <= radius * radius
end
```

**Rounded rectangle corners:**
```ruby
def is_in_rounded_corner?(x, y, size, radius)
  # Check if in one of the 4 corners
  # If so, check if outside the rounded arc
  # Return true if should be transparent
end
```

### 10. Performance Considerations

- Tempfile operations are slow; consider caching for high-volume generation
- ImageMagick calls have startup overhead
- For production, consider pre-generating templates or using a background job

## Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Only 1/4 of circle visible | Grayscale+alpha format | Use ImageMagick to convert to proper RGBA |
| Dots appear in wrong places | `srand` pollution | Use `Random.new` locally |
| QR doesn't scan | Rounded individual modules | Keep square modules, round container |
| Templates not found | Zeitwerk conflict | Move to `lib/qr_templates/` |
