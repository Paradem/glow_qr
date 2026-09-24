# Rounded Dots Template Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add template 4 "Rounded Dots" - a classic square QR with rounded frame and decorative dots

**Architecture:** New template class extending Base, draws rounded rectangle frame then square QR modules, then scatters dots in frame area

**Tech Stack:** ChunkyPNG for image generation, existing QrTemplates::Base infrastructure

---

## File Structure

- **Create:** `lib/qr_templates/rounded_dots.rb` - New template class
- **Modify:** `app/services/qr_generator_service.rb` - Add template 4 mapping
- **Modify:** `app/models/qr_code.rb` - Add template name and CSS classes

---

## Tasks

### Task 1: Create rounded_dots.rb template

**Files:**
- Create: `.worktrees/phase1/lib/qr_templates/rounded_dots.rb`

- [ ] **Step 1: Write rounded_dots.rb**

```ruby
# frozen_string_literal: true

module QrTemplates
  class RoundedDots < Base
    def render_png
      png = ChunkyPNG::Image.new(image_size, image_size, ChunkyPNG::Color::WHITE)

      draw_border(png)
      draw_qr_code(png)
      draw_decorative_dots(png)

      png.to_s
    end

    private

    def image_size
      @image_size ||= qr_pixel_size + (padding * 2) + (border_width * 2)
    end

    def module_size
      options[:module_size] || 10
    end

    def qr_size
      qrcode.modules.size
    end

    def qr_pixel_size
      qr_size * module_size
    end

    def padding
      15
    end

    def border_width
      4
    end

    def corner_radius
      40
    end

    def qr_offset
      border_width + padding
    end

    def draw_border(png)
      fg = ChunkyPNG::Color(options[:foreground] || "black")

      image_size.times do |y|
        image_size.times do |x|
          next unless is_on_border?(x, y)
          png[x, y] = fg
        end
      end
    end

    def is_on_border?(x, y)
      return true if is_on_rounded_rect_edge?(x, y, 0, 0, image_size, image_size, corner_radius)
      false
    end

    def is_on_rounded_rect_edge?(px, py, rx, ry, rw, rh, radius)
      inner_x = rx + radius
      inner_y = ry + radius
      inner_w = rw - radius * 2
      inner_h = rh - radius * 2

      return false if px < rx || px >= rx + rw || py < ry || py >= ry + rh

      in_corner = false
      corner_x = nil
      corner_y = nil

      if px < inner_x && py < inner_y
        corner_x = inner_x
        corner_y = inner_y
        in_corner = true
      elsif px >= inner_x + inner_w && py < inner_y
        corner_x = inner_x + inner_w - 1
        corner_y = inner_y
        in_corner = true
      elsif px < inner_x && py >= inner_y + inner_h
        corner_x = inner_x
        corner_y = inner_y + inner_h - 1
        in_corner = true
      elsif px >= inner_x + inner_w && py >= inner_y + inner_h
        corner_x = inner_x + inner_w - 1
        corner_y = inner_y + inner_h - 1
        in_corner = true
      end

      if in_corner
        dx = px - corner_x
        dy = py - corner_y
        return dx * dx + dy * dy <= radius * radius
      end

      on_edge = (px == rx || px == rx + rw - 1 || py == ry || py == ry + rh - 1)

      if px < inner_x || px >= inner_x + inner_w
        return on_edge
      end
      if py < inner_y || py >= inner_y + inner_h
        return on_edge
      end

      false
    end

    def draw_qr_code(png)
      fg = ChunkyPNG::Color(options[:foreground] || "black")

      qrcode.modules.each_with_index do |row, y|
        row.each_with_index do |is_dark, x|
          next unless is_dark
          px = qr_offset + (x * module_size)
          py = qr_offset + (y * module_size)

          module_size.times do |mx|
            module_size.times do |my|
              png[px + mx, py + my] = fg
            end
          end
        end
      end
    end

    def draw_decorative_dots(png)
      fg = ChunkyPNG::Color(options[:foreground] || "black")

      srand(42)

      dot_count.times do
        dot_x = rand(image_size)
        dot_y = rand(image_size)

        next if is_in_qr_area?(dot_x, dot_y)
        next if is_on_border?(dot_x, dot_y)

        dot_radius = dot_size / 2

        dot_size.ceil.times do |cy|
          dot_size.ceil.times do |cx|
            dx = cx - dot_radius
            dy = cy - dot_radius
            if dx * dx + dy * dy <= dot_radius * dot_radius
              px = (dot_x - dot_radius + cx).round
              py = (dot_y - dot_radius + cy).round
              png[px, py] = fg if px >= 0 && px < image_size && py >= 0 && py < image_size
            end
          end
        end
      end
    end

    def dot_count
      400
    end

    def dot_size
      7
    end

    def is_in_qr_area?(x, y)
      x >= qr_offset && x < qr_offset + qr_pixel_size &&
        y >= qr_offset && y < qr_offset + qr_pixel_size
    end
  end
end
```

- [ ] **Step 2: Verify syntax**

Run: `cd .worktrees/phase1 && ruby -c lib/qr_templates/rounded_dots.rb`
Expected: Syntax OK

- [ ] **Step 3: Test generation**

Run:
```bash
cd .worktrees/phase1 && bin/rails runner "
result = QrGeneratorService.generate('https://test.com', template: 4)
File.binwrite('debug_rounded_dots.png', result[:png_data])
puts 'Success: ' + result[:png_data].size.to_s + ' bytes'
"
```

- [ ] **Step 4: Commit**

```bash
cd .worktrees/phase1
git add lib/qr_templates/rounded_dots.rb
git commit -m "feat: add RoundedDots template"
```

---

### Task 2: Register template 4 in QrGeneratorService

**Files:**
- Modify: `.worktrees/phase1/app/services/qr_generator_service.rb`

- [ ] **Step 1: Add template 4 mapping**

Edit the TEMPLATES hash in qr_generator_service.rb:

```ruby
TEMPLATES = {
  1 => QrTemplates::Classic,
  2 => QrTemplates::Rounded,
  3 => QrTemplates::CircleFrame,
  4 => QrTemplates::RoundedDots,
  10 => QrTemplates::DiscoBall
}.freeze
```

- [ ] **Step 2: Verify it works**

Run: `cd .worktrees/phase1 && bin/rails runner "result = QrGeneratorService.generate('https://test.com', template: 4); puts result[:png_data].size"`

- [ ] **Step 3: Commit**

```bash
cd .worktrees/phase1
git add app/services/qr_generator_service.rb
git commit -m "feat: register RoundedDots template 4"
```

---

### Task 3: Update QrCode model

**Files:**
- Modify: `.worktrees/phase1/app/models/qr_code.rb`

- [ ] **Step 1: Add template 4 to template_name hash**

```ruby
def template_name
  {
    1 => "Classic",
    2 => "Rounded",
    3 => "Circle Frame",
    4 => "Rounded Dots",
    10 => "Disco Ball"
  }[template] || "Unknown"
end
```

- [ ] **Step 2: Add CSS class for template 4**

```ruby
def image_shape_class
  case template
  when 1 then "rounded-none"
  when 2 then "rounded-2xl"
  when 3, 10 then "rounded-full"
  when 4 then "rounded-2xl"
  else "rounded-none"
  end
end
```

- [ ] **Step 3: Add template 4 to has_neon_border?**

```ruby
def has_neon_border?
  [ 3, 4, 10 ].include?(template)
end
```

- [ ] **Step 4: Commit**

```bash
cd .worktrees/phase1
git add app/models/qr_code.rb
git commit -m "feat: add RoundedDots to QrCode model"
```

---

### Task 4: Verify the template

- [ ] **Step 1: Generate and view the image**

Run:
```bash
cd .worktrees/phase1 && bin/rails runner "
result = QrGeneratorService.generate('https://test.com', template: 4)
File.binwrite('debug_rounded_dots_final.png', result[:png_data])
" && file debug_rounded_dots_final.png
```

- [ ] **Step 2: Read the image to verify**

Open `debug_rounded_dots_final.png` to check:
- Rounded corners on the frame
- Square QR modules inside
- Dots in the frame area

---

## Verification

1. QR code is scannable
2. Rounded frame corners visible
3. Dots visible in frame area (not overlapping QR)
4. Template 4 appears in dropdown on homepage
5. Preview page shows rounded frame with neon glow
