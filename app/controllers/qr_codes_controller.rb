# frozen_string_literal: true

class QrCodesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create
  def create
    @qr_code = QrCode.new(url: params[:url], template: params[:template] || 1)
    @qr_code.save!
    @qr_code.generate_image!

    redirect_to preview_qr_code_path(@qr_code)
  end

  def preview
    @qr_code = QrCode.find_by!(short_code: params[:short_code])
  end
end
