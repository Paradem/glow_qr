require "test_helper"

class QrGeneratorServiceTest < ActiveSupport::TestCase
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
