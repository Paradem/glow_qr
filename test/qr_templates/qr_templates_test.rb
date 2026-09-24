require "test_helper"

class QrTemplatesTest < ActiveSupport::TestCase
  test "classic template renders" do
    result = QrGeneratorService.generate("https://example.com", template: 1)
    assert_not_nil result[:png_data]
  end

  test "rounded template renders" do
    result = QrGeneratorService.generate("https://example.com", template: 2)
    assert_not_nil result[:png_data]
  end

  test "circle frame template renders" do
    result = QrGeneratorService.generate("https://example.com", template: 3)
    assert_not_nil result[:png_data]
  end

  test "disco ball template renders" do
    result = QrGeneratorService.generate("https://example.com", template: 10)
    assert_not_nil result[:png_data]
  end
end
