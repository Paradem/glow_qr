# frozen_string_literal: true

class QrCodesController < ApplicationController
  def create
    @qr_code = QrCode.new(url: params[:url], template: params[:template] || 1)
    return render "pages/home", status: :unprocessable_entity unless @qr_code.valid?

    # Render before saving so encoding failures don't leave incomplete records.
    @qr_code.generate_image!
    @qr_code.save!

    redirect_to preview_qr_code_path(@qr_code), status: :see_other
  rescue RQRCodeCore::QRCodeRunTimeError
    @qr_code.errors.add(:url, "is too long to encode. Please use a shorter link.")
    render "pages/home", status: :unprocessable_entity
  end

  def preview
    @qr_code = QrCode.find_by!(short_code: params[:short_code])
  end
end
