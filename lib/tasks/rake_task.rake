namespace :db do
  desc "Generate default schedules"
  task :generate_default_schedules => :environment do
    file = File.join(Rails.root, 'db', 'generate_default_schedules.rb')
    load(file) if File.exist?(file)
  end

  desc "Update zones lat lng"
  task :update_zone_lat_lng => :environment do
    Zone.all.each do |zone|
      center_zone = Geocoder::Calculations.geographic_center(["#{zone.name}, London, England"])
      zone_address = Geocoder.address([center_zone.first, center_zone.last])
      p '------------------------------ center_zone'
      p zone.name
      p center_zone
      p '------------------------------'
      zone.update_attributes(lat: center_zone.first, lng: center_zone.last, address: zone_address)
      sleep 0.3
    end
  end

  desc "Generate price list"
  task :generate_price_list => :environment do
    file = File.join(Rails.root, 'db', 'generate_price_list.rb')
    load(file) if File.exist?(file)
  end

  desc "Add table describe events and reason codes need to do manual process"
  task :add_manual_events_table => :environment do
    if ManualProcessEvent.count == 0
      Event.all.each do |event|
        case event.static_name
        when "Cancelation - GPDQ Error"
          reason_codes = ReasonCode.where(static_name: ["GPDQ Platform Error", "Back office mistake", "Tech error", "Unspecified"])
          reason_codes.each do |reason_code|      
            ManualProcessEvent.create!(event_id: event.id, reason_code_id: reason_code.id)
          end
        when "Patient Cancellation"
          reason_codes = ReasonCode.where(static_name: ["Patient Cancelled via app", "Patient didn't answer door",
            "Due to delay", "Due to return", "Serious medical issue with Patient"
          ])
          reason_codes.each do |reason_code|
            ManualProcessEvent.create!(event_id: event.id, reason_code_id: reason_code.id)
          end
        when "Doctor Return"
          reason_codes = ReasonCode.where(static_name: ["30 mins before ETA", "15 mins before ETA"])
          reason_codes.each do |reason_code|
            ManualProcessEvent.create!(event_id: event.id, reason_code_id: reason_code.id)
          end
        when "Doctor delayed"
          reason_codes = ReasonCode.where(static_name: ["Late >20 minutes", "Late >40 minutes"])
          reason_codes.each do |reason_code|
            ManualProcessEvent.create!(event_id: event.id, reason_code_id: reason_code.id)
          end
        when "Other Customer Service Event"
          reason_codes = ReasonCode.where(static_name: [
            "ETA outside of marketing promise",
            "Inappropriate behaviour", "Inappropriate behaviour - serious", 
            "Contact with patient after appointment unless instigated by patient",
            "Offering direct services", "Inaccurately charging extra time", "Other"
          ])
          reason_codes.each do |reason_code|
            ManualProcessEvent.create!(event_id: event.id, reason_code_id: reason_code.id)
          end
        when "Pre-auth payment fail"
          reason_code = ReasonCode.where(static_name: "Tech issue").first
          ManualProcessEvent.create!(event_id: event.id, reason_code_id: reason_code.id)
        when "Overcharging"
          reason_code = ReasonCode.where(static_name: "GPDQ manual error").first
          ManualProcessEvent.create!(event_id: event.id, reason_code_id: reason_code.id)
        end
      end
    end
  end
end