class Location < ActiveRecord::Base
  belongs_to :patient
  geocoded_by :address
  # after_validation :geocode
  validates :address, :latitude, :longitude, presence: true

  enum address_type: {home: 0, work: 1}
  def as_json
  {
    uid:     self.id,
    address: self.address,
    latitude: latitude,
    longitude: longitude,
    address_type: address_type.to_s
  }
  end

  def check_exists_address(location_params)
    persisted_location = nil
    if location_params[:latitude].present? && location_params[:longitude].present?
      persisted_location = Location.where(address: location_params[:address], 
        latitude: location_params[:latitude], 
        longitude: location_params[:longitude], 
        address_type: Location.address_types[location_params[:address_type]]).first
    end
    persisted_location
  end
end
