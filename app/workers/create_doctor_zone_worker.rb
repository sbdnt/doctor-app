class CreateDoctorZoneWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  def perform(doctor_id)
    doctor = Doctor.find_by_id(doctor_id)
    doctor.save_eta_with_zones

    file = Logger.new("#{Rails.root}/log/doctor_zone.log")
    file.info("In worker create doctor zone successfully")
  end
end