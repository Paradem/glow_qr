# frozen_string_literal: true

class PagesController < ApplicationController
  def home
    @qr_code = QrCode.new(template: 1)
  end
end
