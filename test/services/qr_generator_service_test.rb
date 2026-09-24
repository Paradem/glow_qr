require "test_helper"

class QrGeneratorServiceTest < ActiveSupport::TestCase
  SCOUTSHOP_URL = "https://www.scoutshop.ca/discount/GROUPSHIPPING?group_order_id=fda18e9e3fad6ae7a595".freeze

  test "automatically sizes every template for long URLs with query strings" do
    expected = RQRCode::QRCode.new(SCOUTSHOP_URL, level: :h).modules
    assert_operator expected.length, :>, 41 # The old fixed version 6 limit.

    QrGeneratorService::TEMPLATES.each_key do |template|
      result = QrGeneratorService.generate(SCOUTSHOP_URL, template: template)
      assert_equal expected, result[:matrix], "Template #{template} must encode the complete URL"
      image = ChunkyPNG::Image.from_blob(result[:png_data])
      assert_equal image.width, image.height
      assert_operator image.width, :>, expected.length
    end
  end

  test "preserves encoded characters, multiple query parameters and fragments" do
    url = "#{SCOUTSHOP_URL}&return_to=%2Fcart%3Fnote%3Da%2Bb&source=email#checkout"
    result = QrGeneratorService.generate(url)
    assert_equal RQRCode::QRCode.new(url, level: :h).modules, result[:matrix]
  end

  test "transparent templates use compatible RGBA PNGs" do
    [ 2, 3, 10 ].each do |template|
      png = QrGeneratorService.generate(SCOUTSHOP_URL, template: template)[:png_data]
      assert_equal 6, png.getbyte(25), "Template #{template} must use RGBA color type 6"
    end
  end

  test "generates QR matrix from URL" do
    result = QrGeneratorService.generate("https://example.com")
    assert_not_nil result[:matrix]
    assert result[:matrix].length > 0
  end

  test "matrix is square" do
    result = QrGeneratorService.generate("https://example.com")
    size = result[:matrix].length
    assert result[:matrix].all? { |row| row.length == size }
  end

  test "returns image data as PNG" do
    result = QrGeneratorService.generate("https://example.com")
    assert_not_nil result[:png_data]
    assert result[:png_data].start_with?("\x89PNG".b)
  end

  test "applies template styling" do
    result = QrGeneratorService.generate("https://example.com", template: 10)
    assert_not_nil result[:png_data]
  end
end
