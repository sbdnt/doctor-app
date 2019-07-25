class PriceItem < ActiveRecord::Base
  acts_as_paranoid
  validates :name, presence: true, uniqueness: true
  validates :quantity, presence: true, numericality: { only_integer: true,  greater_than_or_equal_to: 0}
  validates :price_per_unit, presence: true, numericality: { greater_than_or_equal_to: 0}
  belongs_to :price_category, class_name: "PriceCategory", foreign_key: 'category_id'
  has_many :items_invoices
  # has_many :items_invoices, dependent: :destroy
  # has_many :appointment_fees, dependent: :destroy, foreign_key: "price_item_id"
  #validates :is_default, uniqueness: {scope: :category_id}, if: proc{|pr| pr.is_default == true}

  def as_json(options = {})
    {
      uid: id,
      name: name,
      price_per_unit: price_per_unit.to_f,
      quantity: quantity,
      category_id: category_id,
      is_default: is_default,
      editable: editable,
      desc: description
    }
  end

  def as_json_for_charges(appointment_id)
    puts "price_type = #{self.price_type.inspect}"
    appointment = Appointment.find_by(id: appointment_id)
    case self.price_type
    when "appointment_fee"
      price = appointment.appointment_fee.to_f
      puts "price = #{price.inspect}"
      {
        uid: id,
        name: name,
        price_per_unit: price,
        quantity: quantity,
        category_id: category_id,
        is_default: is_default,
        editable: editable,
        desc: description
      }
    when "voucher"
      discount = appointment.voucher_discount
      {
        uid: id,
        name: name,
        price_per_unit: price_per_unit,
        quantity: quantity,
        item_type: 'voucher',
        discount: discount,
        category_id: category_id,
        is_default: is_default,
        editable: editable,
        desc: description
      }
    else
      {
        uid: id,
        name: name,
        price_per_unit: price_per_unit.to_f,
        quantity: quantity,
        category_id: category_id,
        is_default: is_default,
        editable: editable,
        desc: description
      }
    end     
  end

  def as_json_for_invoice(invoice_id)
    {
      uid: id,
      name: name,
      price_per_unit: ItemsInvoice.find_by(price_item_id: self.id, invoice_id: invoice_id).try(:item_price).to_f,
      quantity: ItemsInvoice.find_by(price_item_id: self.id, invoice_id: invoice_id).try(:quantity),
      category_id: category_id,
      is_default: is_default,
      desc: description
    }
  end
end