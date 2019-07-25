class PriceCategory < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :category_order, presence: true, uniqueness: true, numericality: { only_integer: true,  greater_than: 0}
  has_many :price_items, class_name: "PriceItem", foreign_key: 'category_id', dependent: :destroy
  has_many :price_items_not_default, -> { where is_default: false, allow_doctor_add: true }, class_name: "PriceItem", foreign_key: 'category_id'
  scope :except_apt_fee_cat, -> { where.not cat_type: "appointment_fee" }
  scope :except_apt_extension_cat, -> { where.not cat_type: "extension" }
  scope :except_voucher_cat, -> { where.not cat_type: "voucher" }
  default_scope {order('category_order ASC')}
  scope :allow_doctor_view, -> {where(allow_doctor_view: true)}

  def as_json(options = {})
    {
      uid: id,
      name: name,
      items: price_items_not_default,
      allow_expand: allow_expand,
      allow_edit_price: allow_edit_price,
      allow_patient_expand: allow_patient_expand
    }
  end

  def as_json_for_invoice(price_item_ids, invoice_id)
    {
      uid: id,
      name: name,
      items: self.price_items.where(id: price_item_ids).order(:id).map{|x| x.as_json_for_invoice(invoice_id)},
      allow_expand: allow_expand,
      allow_edit_price: allow_edit_price,
      allow_patient_expand: allow_patient_expand
    }
  end

  def as_json_for_charges(appointment_id)
    {
      uid: id,
      name: name,
      items: self.price_items_not_default.map{|x| x.as_json_for_charges(appointment_id)},
      allow_expand: allow_expand,
      allow_edit_price: allow_edit_price,
      allow_patient_expand: allow_patient_expand
    }
  end

  def as_json_for_apt_fee(options = {})
    {
      uid: id,
      name: name,
      items: [self.price_items.first.as_json],
      allow_expand: allow_expand,
      allow_edit_price: allow_edit_price,
      allow_patient_expand: allow_patient_expand
    }
  end

  def as_json_for_single_item(options = {})
    {
      uid: id,
      name: name,
      items: [self.price_items.first.as_json],
      allow_expand: allow_expand,
      allow_edit_price: allow_edit_price,
      allow_patient_expand: allow_patient_expand
    }
  end

end