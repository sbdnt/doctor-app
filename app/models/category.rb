class Category < ActiveRecord::Base
  validates :kind, :title, presence: true
  enum kind: {"Call Directly" => 1, "Information" => 2}
  
  has_many :elements, dependent: :destroy
  accepts_nested_attributes_for :elements, allow_destroy: true

  CALL = 1
  INFORMATION = 2

  scope :informations, -> {where(kind: INFORMATION)}
  scope :call_directories, -> {where(kind: CALL)}

  def self.kind
    {"Call Directly" => 1, "Information" => 2}
  end

  def element_count
    self.elements.count
  end

  def as_json(options = {}) 
    {
      uid: self.id, 
      title: self.title, 
      kind: self.kind
    }
  end

  def self.get_call_directories
    res = []
    self.call_directories.map do |call|
      eles = []
      
      call.elements.map do |el|
        eles << el.as_json
      end
      call.as_json.merge(elements: eles)
    end
  end

  def self.get_informations
    res = []
    self.informations.map do |info|
      eles = []
      
      info.elements.map do |el|
        w_days = []
        el.working_days.map do |wd|
          w_days << wd.as_json
        end
        eles << el.as_json.merge(working_days: w_days)
      end
      info.as_json.merge(elements: eles)
    end
  end
end
