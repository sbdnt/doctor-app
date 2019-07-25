FactoryGirl.define do
  factory :event do
    type_name "MyString"
category 1
standard false
created_via_back_end false
created_via_app false
reason_code_id 1
doctor_sms false
doctor_push false
patient_sms false
patient_push false
in_app_alert false
doctor_credit false
doctor_fine false
patient_credit false
patient_credit false
patient_fee false
  end

end
