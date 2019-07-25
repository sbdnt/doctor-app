class Api::V1::Docs::CalendarsDoc <  ActionController::Base
  def_param_group :default do 
    param :default_week, Integer, desc: "true: load default for week; false: load default for day."
  end

  def_param_group :calendars do 
    param :start_time, String, desc: "String 2015-06-29 08:00"
    param :end_time, String, desc: "Datetime 2015-06-30 08:00"
  end

  def_param_group :apply_default do
    param :auth_token, String, desc: "Authenticate of agency or doctor."
    param :start_time, String, desc: "String 2015-06-29 08:00"
    param :end_time, String, desc: "Datetime 2015-06-30 08:00"
    param :selected_days, Array, desc: "Array for selected days"
  end

  def_param_group :event do
    param :auth_token, String, desc: "Authenticate of agency or doctor."
    param "agency_period[start_at]", String, desc: "String 2015-06-29 08:00"
    param "agency_period[end_at]", String, desc: "Datetime 2015-06-30 08:00"
    param "agency_period[doctor_id]", Integer, desc: "Id of doctor"
    param "agency_period[custom_status]", Integer, desc: "Edit event for doctor"
    param "agency_period[default_common_status]", Integer, desc: "Edit event for default schedule"
    param "agency_period[is_default_week]", Integer, desc: "Edit for default week or default day"
  end

  def self.load_default_schedules_desc
    <<-EOS
      [
        {
            "title": "",
            "start": "2015-06-29 08:00",
            "wday": 1,
            "url": "",
            "status": "default_common_unavailable",
            "color": "red",
            "id": 1921,
            "agency_period_id": 2494
        },
        {
            "title": "",
            "start": "2015-06-29 08:15",
            "wday": 1,
            "url": "",
            "status": null,
            "color": "grey",
            "id": 1922,
            "agency_period_id": null
        },
        {
            "title": "",
            "start": "2015-06-29 08:30",
            "wday": 1,
            "url": "",
            "status": null,
            "color": "grey",
            "id": 1923,
            "agency_period_id": null
        }
        ...
      ]
    EOS
  end

  def self.load_custom_calendars_desc
    <<-EOS
      [
        {
            "title": "",
            "start": "2015-06-29 08:00",
            "wday": 1,
            "url": "",
            "status": "default_common_unavailable",
            "color": "red",
            "id": 1921,
            "agency_period_id": 2494
        },
        {
            "title": "",
            "start": "2015-06-29 08:15",
            "wday": 1,
            "url": "",
            "status": null,
            "color": "grey",
            "id": 1922,
            "agency_period_id": null
        },
        {
            "title": "",
            "start": "2015-06-29 08:30",
            "wday": 1,
            "url": "",
            "status": null,
            "color": "grey",
            "id": 1923,
            "agency_period_id": null
        }
        ...
      ]
    EOS
  end
  
  def self.apply_default_schedule_desc
    <<-EOS
      {"success": true}
    EOS
  end

  def self.update_event_desc
    <<-EOS
      {"success": true}
    EOS
  end
end