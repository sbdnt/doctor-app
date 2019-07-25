class VouchersController < ApplicationController

  # Author: Thanh
  def validate
    voucher = Voucher.where(voucher_code: params[:voucher_code]).first
    if voucher
      if voucher.is_used?
        render json: { message: "This voucher code already used!", status: "error" }
      else
        render json: { message: "This voucher can be used. Amount: #{view_context.number_to_currency(voucher.amount, precision: 2, unit: '£', separator: ".", delimiter: ",")}", status: "success" }
      end
    else
      render json: { message: "This voucher code not found!", status: "error" }
    end
  end
end

