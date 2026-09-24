# GlowQR - Agents

## Project Overview

GlowQR is a Rails 8 QR code generator with multiple template styles.

**Live:** https://glowqr.fly.dev/

## Key Commands

```bash
# Development
bin/rails server

# Deploy
fly deploy

# Console
bin/rails console

# Generate test QR
bin/rails runner "result = QrGeneratorService.generate('https://test.com', template: 10); File.binwrite('test.png', result[:png_data])"
```

## QR Templates

Templates are located in `lib/qr_templates/`. **IMPORTANT:** Do not use `app/templates/` - it conflicts with Rails autoloading.

### Template Files

- `lib/qr_templates/base.rb` - Base class
- `lib/qr_templates/classic.rb` - Standard square QR
- `lib/qr_templates/rounded.rb` - Square QR with rounded container (transparent PNG)
- `lib/qr_templates/circle_frame.rb` - Square QR in circular frame with white inside, transparent outside
- `lib/qr_templates/disco_ball.rb` - Square QR in circular frame with decorative dots

### Template Architecture

1. Templates implement `render_png` returning PNG bytes
2. Use ChunkyPNG for drawing
3. **For transparency:** Generate base with ChunkyPNG, then use ImageMagick to convert to proper RGBA

### Template Registration

Add new templates to:
- `lib/qr_templates/` - Create new template class
- `app/services/qr_generator_service.rb` - Register in `TEMPLATES` hash
- `app/models/qr_code.rb` - Add to `template_name`, `image_shape_class`, `has_neon_border?`
- `app/controllers/pages_controller.rb` - Add to `@templates` array

## PNG Generation with Transparency

**CRITICAL:** ChunkyPNG's grayscale+alpha format (color type 4) doesn't display correctly in many image viewers. Use ImageMagick to create proper RGBA:

```ruby
def convert_to_rgba(png_data)
  Tempfile.create(["qr", ".png"], binmode: true) do |input|
    Tempfile.create(["qr", ".png"], binmode: true) do |output|
      Tempfile.create(["qr", ".png"], binmode: true) do |mask|
        File.binwrite(input.path, png_data)
        # Create mask (white = visible, black = transparent)
        system("magick -size #{size}x#{size} xc:black -fill white -draw 'circle #{center},#{center} #{center},#{(center + radius).to_i}' #{mask.path}")
        # Apply mask
        system("magick #{input.path} -alpha off -colorspace RGB temp_rgb.png && " \
               "magick #{mask.path} -alpha on temp_mask_rgba.png && " \
               "magick temp_rgb.png temp_mask_rgba.png -compose CopyOpacity -composite " \
               "-colorspace sRGB temp_output.png && " \
               "magick temp_output.png #{output.path} && " \
               "rm -f temp_rgb.png temp_mask_rgba.png temp_output.png")
        File.binread(output.path)
      end
    end
  end
end
```

## Random Number Generation

**Never use `srand`** - it pollutes global random state. Use local Random instances:

```ruby
# Bad
srand(42)
rand(100)

# Good
rng = Random.new(42)
rng.rand(100)
```

## Testing Templates

```bash
# Generate all templates
bin/rails runner "
[1, 2, 3, 4, 10].each do |t|
  result = QrGeneratorService.generate('https://test.com', template: t)
  File.binwrite('test_t' + t.to_s + '.png', result[:png_data])
end
"

# Verify PNG format
file test_t*.png
# Should show "8-bit/color RGBA" for templates with transparency
# Should show "1-bit grayscale" for solid templates
```

## Active Storage

QR images are stored via Active Storage with `has_one_attached :image` on QrCode model.

## Deployment

The app runs on Fly.io with:
- SQLite database (in storage volume)
- Port 3000
- ImageMagick installed in Dockerfile

## Key Files

- `lib/qr_templates/` - QR template classes
- `app/services/qr_generator_service.rb` - QR generation orchestrator
- `app/models/qr_code.rb` - QrCode model with template metadata
- `app/views/qr_codes/preview.html.erb` - QR display page
- `app/views/pages/home.html.erb` - Homepage with template selector
