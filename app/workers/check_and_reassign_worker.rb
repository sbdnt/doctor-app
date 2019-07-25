class CheckAndReassignWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(appointment_id)
    appointment = Appointment.find_by_id(appointment_id)
    if appointment.present? && appointment.is_canceled == 'normal'
      if appointment.assigned? || appointment.pending?
        appointment.assign_doctor(false)
      end
    end

  end
end