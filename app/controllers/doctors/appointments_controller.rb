class Doctors::AppointmentsController < ApplicationController
  def index
    params[:sort] ||= 'start_at'
    params[:sort_direction] ||= 'asc'
    live_appointments = Appointment.where(doctor_id: current_doctor.id, is_canceled: 0).live
    if params[:query].present?
      live_appointments = live_appointments.where('name ilike ?',  "#{params[:query]}%")
    end
    @live_appointments = live_appointments.order( params[:sort] + ' ' + params[:sort_direction] )

    past_appointments = Appointment.where(doctor_id: current_doctor.id, is_canceled: 0).complete
    if params[:query].present?
      past_appointments = past_appointments.where('name ilike ?',  "#{params[:query]}%")
    end
    @past_appointments = past_appointments.order( params[:sort] + ' ' + params[:sort_direction] )

    params[:sort_direction] = params[:sort_direction] == 'asc' ? 'desc' : 'asc'
  end
end
