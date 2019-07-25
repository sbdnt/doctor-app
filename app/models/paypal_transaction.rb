class PaypalTransaction < ActiveRecord::Base
  belongs_to :appointment
  ON_BOOKED = "Patient booked appointment successfully"
  ON_CONFIRM = "Doctor confirms appointment started"
  ON_CANCELED = "Patient canceled appointment"
  ON_COMPLETE = "Doctor confirms appointment complete"

  enum status: {created: 1, approved: 2, failed: 3, canceled: 4, expired: 5, pending: 6, in_progress: 7}
  enum payment_type: {capture: 1, collection: 2, payment: 3}
end
