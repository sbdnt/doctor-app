class Credit < ActiveRecord::Base
	enum credit_type: {:CS => 1, :Sponsor=> 2}
	
	validates :patient_id, :credit_type, :presence => true
  validates :credit_number, presence: true, :format => { :with => /\A\d+(?:\.\d{0,2})?\z/ }, :numericality => {:greater_than_or_equal => 0}
	belongs_to :patient

	#class methods
  def self.update_used_credits(patient_id, appointment_id)
    credits = Credit.where(patient_id: patient_id, is_used: false).where("expired_date >= ? ", Time.now.to_date)
  	credits.update_all(is_used: true, used_at: Time.now, used_appointment_id: appointment_id)
  end

end
