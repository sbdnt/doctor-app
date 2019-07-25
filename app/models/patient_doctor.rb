class PatientDoctor < ActiveRecord::Base
  belongs_to :patient
  belongs_to :doctor

  def show_eta
    if self.eta.present?
      "#{self.eta.round(0)} mins"
    else
      "N/A"
    end
  end

  def show_km
    if self.km.present?
      "#{self.km} km"
    else
      "N/A"
    end
  end

  def latitude
  end

  def longitude
  end

end
