
class ReassignDoctorToAppointmentWorker
  include Sidekiq::Worker
  # sidekiq_options queue: :api
  sidekiq_options retry: false
  
  def perform
    Doctor.reassign
  end
end