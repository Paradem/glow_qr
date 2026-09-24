# frozen_string_literal: true

require "rqrcode"
require "rqrcode_png"
require "qr_templates"

class QrGeneratorService
  TEMPLATES = {
    1 => QrTemplates::Classic,
    2 => QrTemplates::Rounded,
    3 => QrTemplates::CircleFrame,
    10 => QrTemplates::DiscoBall
  }.freeze

  def self.generate(url, template: 1, customizations: {})
    qrcode = RQRCode::QRCode.new(url, level: :h, size: 6)
    template_class = TEMPLATES[template] || QrTemplates::Classic

    customizations[:foreground] ||= "black"
    customizations[:background] ||= "white"

    renderer = template_class.new(qrcode, customizations)
    png_data = renderer.render_png

    { matrix: qrcode.instance_variable_get(:@qrcode).modules, png_data: png_data }
  end
end
