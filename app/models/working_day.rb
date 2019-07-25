class WorkingDay < ActiveRecord::Base
  belongs_to :element
  validates :week_day, :close_at, :open_at, presence: true, if: proc{|w| w.element.present? && w.element.category.kind == Element::INFORMATION}

  def as_json(options = {})
    {
      id: self.id,
      close_at: self.close_at.strftime("%H:%M"),
      open_at: self.open_at.strftime("%H:%M"),
      element_id: self.element_id,
      week_day: self.week_day
    }
  end
end
