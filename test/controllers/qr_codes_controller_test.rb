# frozen_string_literal: true

require "test_helper"

class QrCodesControllerTest < ActionDispatch::IntegrationTest
  test "POST /qr_codes creates QR code and redirects" do
    assert_difference "QrCode.count", 1 do
      post "/qr_codes", params: { url: "https://example.com", template: "1" }
    end

    assert_redirected_to preview_qr_code_path(QrCode.last.short_code)
  end

  test "home shows an accessible generator and all templates" do
    get root_path
    assert_response :success
    assert_select "label[for='url']", /Add your link/
    assert_select "input[type='radio'][name='template']", count: 4
    assert_select "input[name='template'][value='1'][checked]"
  end

  test "creates and previews the complete Scoutshop discount URL in every style" do
    url = "https://www.scoutshop.ca/discount/GROUPSHIPPING?group_order_id=fda18e9e3fad6ae7a595"

    QrGeneratorService::TEMPLATES.each_key do |template|
      assert_difference "QrCode.count", 1 do
        post qr_codes_path, params: { url: url, template: template }
      end
      qr = QrCode.last
      assert_equal url, qr.url
      assert_equal template, qr.template
      assert qr.image.attached?
      follow_redirect!
      assert_response :success
      assert_select ".destination p", text: url
      assert_select "a[download][href*='disposition=attachment']"
    end
  end

  test "invalid input renders helpful errors and preserves the selected style" do
    [ "", "not-a-url", "https://example.com/#{'a' * 2048}" ].each do |url|
      assert_no_difference "QrCode.count" do
        post qr_codes_path, params: { url: url, template: 3 }
      end
      assert_response :unprocessable_entity
      assert_select "[role='alert']"
      assert_select "input[name='url'][value=?]", url
      assert_select "input[name='template'][value='3'][checked]"
    end
  end

  test "encoding overflow does not save an incomplete QR code" do
    assert_no_difference [ "QrCode.count", "ActiveStorage::Blob.count" ] do
      post qr_codes_path, params: { url: "https://example.com/#{'a' * 1500}", template: 1 }
    end
    assert_response :unprocessable_entity
    assert_select "[role='alert']", /too long to encode/
  end

  test "invalid template returns a form error" do
    assert_no_difference "QrCode.count" do
      post qr_codes_path, params: { url: "https://example.com", template: 4 }
    end
    assert_response :unprocessable_entity
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
