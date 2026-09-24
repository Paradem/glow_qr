# frozen_string_literal: true

require "application_system_test_case"

class GenerateQrTest < ApplicationSystemTestCase
  test "complete QR generation flow" do
    visit root_url

    fill_in "url", with: "https://example.com"
    click_button "Generate for free"

    assert_selector "h1", text: /Your QR Code is Ready!/
    assert_selector "a[download]"
  end
end
