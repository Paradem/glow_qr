# frozen_string_literal: true

require "test_helper"

class ShortCodeServiceTest < ActiveSupport::TestCase
  test "generates unique codes" do
    codes = 100.times.map { ShortCodeService.generate }
    assert_equal codes.uniq.length, codes.length
  end
end
