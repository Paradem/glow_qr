# frozen_string_literal: true

class QrCode < ApplicationRecord
  before_validation :generate_short_code, on: :create

  has_one_attached :image

  validates :url, presence: true, length: { maximum: 2048 }
  validates :short_code, uniqueness: true, length: { is: 6 }
  validates :template, presence: true,
                       inclusion: { in: 1..10,
                                    message: "must be between 1 and 10" }

  def to_param
    short_code
  end

  def generate_short_code
    self.short_code ||= ShortCodeService.generate_unique(
      existing_codes: QrCode.pluck(:short_code)
    )
  end

  def template_name
    {
      1 => "Classic",
      2 => "Transparent PNG",
      3 => "Circle Frame",
      10 => "Disco Ball"
    }[template] || "Unknown"
  end

  def image_shape_class
    case template
    when 1 then "rounded-none"
    when 2 then "rounded-2xl"
    when 3, 10 then "rounded-full"
    else "rounded-none"
    end
  end

  def has_neon_border?
    [ 3, 10 ].include?(template)
  end

  def generate_image!
    result = QrGeneratorService.generate(url, template: template, customizations: customizations || {})
    image.attach(
      io: StringIO.new(result[:png_data]),
      filename: "#{short_code}.png",
      content_type: "image/png"
    )
  end
end
