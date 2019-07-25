class Api::V1::Patients::CustomerCaresController < Api::V1::BaseApiController
  skip_before_filter :api_authenticate_patient!
  api :GET, '/patients/customer_cares/faq_list', "Get FAQ list"
  # param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  example Api::V1::Docs::Patients::CustomerCaresDoc.faq_list
  def faq_list
    faq_list = Help.where(is_published: true)
    if faq_list.count > 0
      render status: 200, json: {success: true, faq_list: faq_list.map{|item| item.as_json}}
    else
      render status: 200, json: {success: true, faq_list: []}
    end
  end

  api :GET, '/patients/customer_cares/gpdq_email', "Get GPDQ Email list"
  # param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  example Api::V1::Docs::Patients::CustomerCaresDoc.gpdq_email
  def gpdq_email
    email_list = GpdqEmail.where(is_published: true)
    if email_list.count > 0
      render status: 200, json: {success: true, email_list: email_list.map{|item| item.as_json}}
    else
      render status: 200, json: {success: true, email_list: []}
    end
  end

  api :GET, '/patients/customer_cares/gpdq_phone', "Get GPDQ Phone list"
  # param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  example Api::V1::Docs::Patients::CustomerCaresDoc.gpdq_phone
  def gpdq_phone
    phone_list = GpdqPhone.where(is_published: true)
    if phone_list.count > 0
      render status: 200, json: {success: true, phone_list: phone_list.map{|item| item.as_json}}
    else
      render status: 200, json: {success: true, phone_list: []}
    end
  end

end
