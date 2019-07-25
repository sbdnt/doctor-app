module Api
  module V1
    class VouchersController < ActionController::Base

      api :GET, '/vouchers/:voucher_code/validate', "Check valid voucher code"
      param :auth_token, String, desc: "Authentication token", required: true
      param :voucher_code, String, desc: "Voucher code", required: true
      example Api::V1::Docs::VouchersDoc.validate
      def validate
        current_patient = Patient.find_by_auth_token(params[:auth_token])
        if current_patient.nil?
          render :json => { :message => t('controller.common.unauthorized')},
                 :status => 401
          return
        end

        voucher = Voucher.where(voucher_code: params[:voucher_code]).first
        if voucher
          is_valid = voucher.check_valid_code(current_patient.id)

          if is_valid
            render json: { success: true, message: "This voucher can be used" }, status: :ok
          else
            render json: { success: false, message: "This voucher code already used!" }, status: :ok
          end
        else
          render json: { success: false, message: "This voucher code not found!" }, status: :ok
        end
      end

    end
  end
end