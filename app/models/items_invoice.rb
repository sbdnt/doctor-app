class ItemsInvoice < ActiveRecord::Base
  belongs_to :price_item
  belongs_to :invoice
  # validates :invoice_id, :price_item_id, presence: true
  # after_create :update_item_price

  def as_json
    {
      uid: self.id,
      item_price: self.item_price,
      category_name: PriceItem.find(self.price_item_id).price_category.name,
      category_id: PriceItem.find(self.price_item_id).price_category.id
    }
  end

  def update_item_price
    price = self.price_item.price_per_unit || 0
    self.update_attributes(item_price: price)
  end

  def price_item
    PriceItem.with_deleted.find(price_item_id)
  end

end