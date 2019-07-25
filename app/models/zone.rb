class Zone < ActiveRecord::Base
  has_many :doctor_zones, :dependent => :destroy
  has_many :sub_zones, :dependent => :destroy
  validates :name, presence: true, uniqueness: true
  before_create :update_lat_lng
  before_save :update_lat_lng, if: proc{|z| z.name_changed?}

  def self.order_by_ids(ids)
    order_by = ["case"]
    ids.each_with_index.map do |id, index|
      order_by << "WHEN id='#{id}' THEN #{index}"
    end
    order_by << "end"
    order(order_by.join(" "))
  end

  def update_lat_lng
    sleep 0.2
    center_zone = Geocoder::Calculations.geographic_center(["#{self.name}, London, England"])
    self.lat = center_zone.first unless self.lat == center_zone.first
    self.lng = center_zone.last unless self.lng == center_zone.last
    sleep 0.1
    self.address = Geocoder.address([self.lat, self.lng])
  end
end
