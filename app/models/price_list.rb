class PriceList < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0}, if: proc {|p| p.price.present?}

  def as_json
    if price_type == 'drug_delivery' || price_type == 'extra'
      price = description
    else
      price = number_to_currency(self.price.to_f, precision: 2, unit: "£", separator: ".", delimiter: ",")
    end
    {
      uid: id,
      name: name,
      price: price
    }
  end

  def as_json_for_drug
    {
      uid: id,
      name: name,
      desc: description,
    }
  end
end
