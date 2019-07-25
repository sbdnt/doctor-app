class Help < ActiveRecord::Base
  validates :title, presence: true
  validates :content, presence: true
  def as_json
    {
      uid: self.id,
      title: self.title,
      content: self.content
    }
  end
end
