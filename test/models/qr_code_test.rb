require "test_helper"

class QrCodeTest < ActiveSupport::TestCase
  test "generates short code on create" do
    qr = QrCode.create!(url: "https://example.com")
    assert_not_nil qr.short_code
    assert_equal 6, qr.short_code.length
  end

  test "short code is alphanumeric" do
    qr = QrCode.create!(url: "https://example.com")
    assert_match(/\A[a-z0-9]{6}\z/, qr.short_code)
  end

  test "requires valid url" do
    qr = QrCode.new
    assert_not qr.valid?
    assert_includes qr.errors[:url], "can't be blank"
  end

  test "generates and saves image" do
    qr = QrCode.create!(url: "https://example.com", template: 1)
    qr.generate_image!

    assert qr.image.attached?
    assert_equal "image/png", qr.image.blob.content_type
  end
end
