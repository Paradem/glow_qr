# frozen_string_literal: true

module QrTemplates
  class Rounded < Base
    def render_png
      png = ChunkyPNG::Image.new(image_size, image_size, ChunkyPNG::Color::TRANSPARENT)

      draw_qr_code(png)
      apply_rounded_corners(png)

      png.to_s
    end

    private

    def image_size
      @image_size ||= qr_pixel_size + (padding * 2)
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
      20
    end

    def corner_radius
      40
    end

    def qr_offset
      padding
    end

    def draw_qr_code(png)
      fg = ChunkyPNG::Color(options[:foreground] || "black")
      bg = ChunkyPNG::Color(options[:background] || "white")

      qrcode.modules.each_with_index do |row, y|
        row.each_with_index do |is_dark, x|
          color = is_dark ? fg : bg
          px = qr_offset + (x * module_size)
          py = qr_offset + (y * module_size)

          module_size.times do |mx|
            module_size.times do |my|
              png[px + mx, py + my] = color
            end
          end
        end
      end
    end

    def apply_rounded_corners(png)
      image_size.times do |y|
        image_size.times do |x|
          if is_in_rounded_corner?(x, y)
            png[x, y] = ChunkyPNG::Color::TRANSPARENT
          end
        end
      end
    end

    def is_in_rounded_corner?(x, y)
      radius = corner_radius

      return false if x >= radius && x < image_size - radius
      return false if y >= radius && y < image_size - radius

      corner_x = x < radius ? radius : image_size - radius - 1
      corner_y = y < radius ? radius : image_size - radius - 1

      dx = x - corner_x
      dy = y - corner_y

      dx * dx + dy * dy > radius * radius
    end
  end
end
