# frozen_string_literal: true

module QrTemplates
  class Classic < Base
    def render_png
      qrcode.as_png(
        bit_depth: 8,
        color_mode: 0,
        color: options[:foreground],
        fill: options[:background],
        module_px_size: options[:module_size] || 6,
        file_width: 400,
        file_height: 400
      ).to_s
    end
  end
end
