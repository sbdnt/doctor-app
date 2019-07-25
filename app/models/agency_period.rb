class AgencyPeriod < ActiveRecord::Base
  belongs_to :agency
  belongs_to :period
  enum default_common_status: {default_common_unavailable: 0, default_common_available: 1}
  enum default_specific_status: {default_specific_unavailable: 0, default_specific_available: 1}
  enum custom_status: {custom_unavailable: 0, custom_available: 1}

  #before_save :apply_default_specific_doctor, if: proc{|ap| ap.default_specific_status_changed?}
  #before_save :apply_default_common_doctor, if: proc{|ap| ap.default_common_status_changed?}

  def self.default_common_status
    {default_common_unavailable: 0, default_common_available: 1}
  end
  def self.default_specific_status
    {default_specific_unavailable: 0, default_specific_available: 1}
  end
  def self.custom_status
    {custom_unavailable: 0, custom_available: 1}
  end

  def apply_default_specific_doctor
    if self.default_specific_available? && self.custom_status.nil?
      self.custom_status = "custom_available"
    elsif self.default_specific_unavailable? && self.custom_status.nil?
      self.custom_status = "custom_unavailable"
    end
  end
  def apply_default_common_doctor
    if self.default_common_available? && self.custom_status.nil? && self.default_specific_status.nil?
      self.custom_status = "custom_available"
      self.default_specific_status = "default_specific_available"
    elsif self.default_common_unavailable? && self.custom_status.nil? && self.default_specific_status.nil?
      self.custom_status = "custom_unavailable"
      self.default_specific_status = "default_specific_available"
    end
  end
end
