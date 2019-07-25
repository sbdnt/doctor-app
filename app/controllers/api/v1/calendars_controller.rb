class Api::V1::CalendarsController < Api::V1::SchedulesController
  before_filter :api_authenticate_doctor!
  skip_before_filter :api_authenticate_agency!
end