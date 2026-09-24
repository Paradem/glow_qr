# frozen_string_literal: true

class QrCode < ApplicationRecord
  before_validation :generate_short_code, on: :create

  has_one_attached :image

  normalizes :url, with: ->(url) { url.strip }

  validates :url, presence: true, length: { maximum: 2048 }
  validate :http_url
  validates :short_code, uniqueness: true, length: { is: 6 }
  validates :template, presence: true,
                       inclusion: { in: QrGeneratorService::TEMPLATES.keys,
                                    message: "must be one of the available styles" }

  def http_url
    return if url.blank?

    uri = URI.parse(url)
    errors.add(:url, "must be a valid http:// or https:// link") unless uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
    errors.add(:url, "must be a valid http:// or https:// link")
  end
  private :http_url

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
