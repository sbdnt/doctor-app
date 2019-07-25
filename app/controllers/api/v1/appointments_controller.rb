module Api
  module V1
    class AppointmentsController < ActionController::Base
      api :GET, '/appointments/fee', "Get appointment fee"
      example Api::V1::Docs::AppointmentsDoc.fee
      def fee
        apointment_fee = PriceItem.where(is_default: true).sum(:price_per_unit).to_f
        render json: { fee: apointment_fee }, status: 200
      end
    end
  end
end