class GpdqSetting < ActiveRecord::Base
	enum time_unit: {:day=>0, :month=>1, :year=>2}
	validates :name, :value,  :presence => true
	validates :name, uniqueness: true

end
