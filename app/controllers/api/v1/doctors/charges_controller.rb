module Api
  module V1
    module Doctors
      class ChargesController < BaseController

        api :GET, "/doctors/charges", "Get charges list: only get categories have items and items are not default of categories."
        param_group :base_group, Api::V1::Docs::Doctors::SessionsDoc
        example Api::V1::Docs::Doctors::ChargesDoc.charges
        def charges
          # Get categories have items
          category_ids = PriceItem.where(is_default: false).pluck(:category_id).uniq
          @categories = PriceCategory.includes(:price_items_not_default).where(id: category_ids).allow_doctor_view
          render json: { categories: @categories.map{|c| c.as_json}}, status: 200
        end

        api :GET, "/doctors/charges_with_appointment", "New Version Get charges list: only get categories have items and items are not default of categories."
        param_group :base_group, Api::V1::Docs::Doctors::SessionsDoc
        param :appointment_id, Integer, desc: "Appointment's id", :required => true
        example Api::V1::Docs::Doctors::ChargesDoc.charges_with_appointment
        def charges_with_appointment
          # Get categories have items
          appointment = Appointment.find_by(id: params[:appointment_id])
          puts "appointment = #{appointment.inspect}"
          category_ids = PriceItem.where(is_default: false).pluck(:category_id).uniq
          @categories = PriceCategory.includes(:price_items_not_default).where(id: category_ids).allow_doctor_view
          puts "@categories = #{@categories.inspect}"
          
          render json: {categories: @categories.map{|c| c.as_json_for_charges(appointment.id)}}, status: 200
        end
      end
    end
  end
end