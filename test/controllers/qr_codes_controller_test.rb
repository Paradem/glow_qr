# frozen_string_literal: true

require "test_helper"

class QrCodesControllerTest < ActionDispatch::IntegrationTest
  test "POST /qr_codes creates QR code and redirects" do
    assert_difference "QrCode.count", 1 do
      post "/qr_codes", params: { url: "https://example.com", template: "1" }
    end

    assert_redirected_to preview_qr_code_path(QrCode.last.short_code)
  end

test "GET /preview/:short_code shows QR code" do
    qr = QrCode.create!(url: "https://example.com", template: 1)
    qr.generate_image!

    get preview_qr_code_path(qr.short_code)
    assert_response :success
    assert_select "a[href='/']", /GlowQR/
    assert_select "img[alt='QR Code']"
  end
end
