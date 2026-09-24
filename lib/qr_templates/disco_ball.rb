# frozen_string_literal: true

require "open3"

module QrTemplates
  class DiscoBall < Base
    def render_png
      Tempfile.create([ "qr", ".png" ], binmode: true) do |temp_input|
        Tempfile.create([ "qr", ".png" ], binmode: true) do |temp_output|
          Tempfile.create([ "qr", ".png" ], binmode: true) do |temp_mask|
            generate_base_qr(temp_input.path)
            create_circle_mask(temp_mask.path)
            apply_mask_and_convert(temp_input.path, temp_mask.path, temp_output.path)
            File.binread(temp_output.path)
          end
        end
      end
    end

    private

    def image_size
      @image_size ||= ((circle_radius + border_width) * 2).ceil
    end

    def qr_size
      qrcode.modules.size
    end

    def module_size
      options[:module_size] || 8
    end

    def qr_pixel_size
      qr_size * module_size
    end

    def center
      image_size / 2
    end

    def circle_radius
      @circle_radius ||= begin
        diagonal = (qr_pixel_size + module_size * 8) * Math.sqrt(2)
        (diagonal / 2) + 15
      end
    end

    def border_width
      3
    end

    def generate_base_qr(output_path)
      png = ChunkyPNG::Image.new(image_size, image_size, ChunkyPNG::Color::WHITE)

      draw_border_circle(png)
      draw_qr_code(png)
      draw_decorative_circles(png)

      File.binwrite(output_path, png.to_s)
    end

    def create_circle_mask(output_path)
      _stdout, _stderr, status = Open3.capture3(
        "magick", "-size", "#{image_size}x#{image_size}", "xc:black",
        "-fill", "white", "-draw", "circle #{center},#{center} #{center},#{(center + circle_radius).to_i}",
        output_path
      )
      raise "ImageMagick failed: #{_stderr}" unless status.success?
    end

    def apply_mask_and_convert(input_path, mask_path, output_path)
      temp_rgb = "/tmp/qr_temp_rgb_#{$$}_#{rand(1000)}.png"
      temp_mask_rgba = "/tmp/qr_temp_mask_#{$$}_#{rand(1000)}.png"
      temp_output = "/tmp/qr_temp_output_#{$$}_#{rand(1000)}.png"

      begin
        _stdout, _stderr, status = Open3.capture3("magick", input_path, "-alpha", "off", "-colorspace", "RGB", temp_rgb)
        raise "ImageMagick failed: #{_stderr}" unless status.success?

        _stdout, _stderr, status = Open3.capture3("magick", mask_path, "-alpha", "on", temp_mask_rgba)
        raise "ImageMagick failed: #{_stderr}" unless status.success?

        _stdout, _stderr, status = Open3.capture3("magick", temp_rgb, temp_mask_rgba, "-compose", "CopyOpacity", "-composite", "-colorspace", "sRGB", temp_output)
        raise "ImageMagick failed: #{_stderr}" unless status.success?

        _stdout, _stderr, status = Open3.capture3("magick", temp_output, "PNG32:#{output_path}")
        raise "ImageMagick failed: #{_stderr}" unless status.success?
      ensure
        File.delete(temp_rgb) if File.exist?(temp_rgb)
        File.delete(temp_mask_rgba) if File.exist?(temp_mask_rgba)
        File.delete(temp_output) if File.exist?(temp_output)
      end
    end

    def draw_border_circle(png)
      fg = ChunkyPNG::Color("black")
      outer_radius_sq = (circle_radius + border_width) ** 2
      inner_radius_sq = circle_radius ** 2

      image_size.times do |y|
        image_size.times do |x|
          dx = x - center
          dy = y - center
          dist_sq = dx * dx + dy * dy
          if inner_radius_sq <= dist_sq && dist_sq <= outer_radius_sq
            png[x, y] = fg
          end
        end
      end
    end

    def draw_qr_code(png)
      fg = ChunkyPNG::Color("black")
      qr_offset = (image_size - qr_pixel_size) / 2

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

    def draw_decorative_circles(png)
      fg = ChunkyPNG::Color("black")
      # Keep decoration outside the QR code's four-module quiet zone.
      qr_half = qr_pixel_size / 2 + module_size * 4

      rng = Random.new(42)

      800.times do
        angle = rng.rand * 2 * Math::PI

        abs_cos = Math.cos(angle).abs
        abs_sin = Math.sin(angle).abs

        qr_edge_dist = [ qr_half / abs_cos, qr_half / abs_sin ].min

        min_dist = qr_edge_dist + module_size
        max_dist = circle_radius - 4

        next if min_dist >= max_dist

        distance = min_dist + rng.rand * (max_dist - min_dist)

        ex = center + Math.cos(angle) * distance
        ey = center + Math.sin(angle) * distance

        circle_size = (module_size * 0.9).round
        circle_radius_inner = circle_size / 2.0

        circle_size.ceil.times do |cy|
          circle_size.ceil.times do |cx|
            dx = cx - circle_radius_inner
            dy = cy - circle_radius_inner
            if dx * dx + dy * dy <= circle_radius_inner * circle_radius_inner
              px = (ex - circle_radius_inner + cx).round
              py = (ey - circle_radius_inner + cy).round
              png[px, py] = fg if px >= 0 && px < image_size && py >= 0 && py < image_size
            end
          end
        end
      end
    end
  end
end
