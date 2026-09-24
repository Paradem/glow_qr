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

  test "rejects non-web and malformed URLs" do
    [ "javascript:alert(1)", "ftp://example.com", "https://", "not a url" ].each do |url|
      assert_not QrCode.new(url: url).valid?, url
    end
  end

  test "trims surrounding whitespace without changing query parameters" do
    url = "https://example.com/discount/GROUPSHIPPING?group_order_id=abc&return_to=%2Fcart#checkout"
    qr = QrCode.new(url: "  #{url}\n")
    assert qr.valid?
    assert_equal url, qr.url
  end

  test "only registered templates are valid" do
    assert_not QrCode.new(url: "https://example.com", template: 4).valid?
  end

  test "generates and saves image" do
    qr = QrCode.create!(url: "https://example.com", template: 1)
    qr.generate_image!

    assert qr.image.attached?
    assert_equal "image/png", qr.image.blob.content_type
  end
end
