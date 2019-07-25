class Invoice < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  validates :appointment_id, presence: true, uniqueness: true
  enum status: {pending: 0, closed: 1}

  has_many :items_invoices, dependent: :destroy
  has_many :price_items, -> { order 'is_default DESC, item_price ASC' }, through: :items_invoices
  belongs_to :appointment, class_name: "Appointment", foreign_key: "appointment_id"
  accepts_nested_attributes_for :price_items, :allow_destroy => true
  # before_save :update_status, if: proc{|inv| inv.status_changed?}
  after_save :make_payment_for_invoice, if: proc{|inv| inv.total_prices_changed? && inv.total_prices.to_f != 0.0}

  # VAT Tax
  # VAT = 20

  # after_save :update_total_price

  def self.modify_status
    {pending: 0, closed: 1}
  end

  def update_total_price
    return if self.status != 'pending'
    total_prices = 0
    total_extra = 0
    # vat = 0
    
    puts "=============Voucher logs================="
    puts "discount = #{discount.inspect}"
    item_list = ItemsInvoice.where( invoice_id: self.id )
    if item_list.size > 0
      total_prices = item_list.map{|x| x.item_price * x.quantity}.sum
      total_prices += self.appointment.appointment_fee if self.appointment.appointment_fee.present?
      total_prices += self.appointment.get_extra_fee if self.appointment.get_extra_fee > 0
      # vat = total_prices*Invoice::VAT/100
      if item_list.select{|x| x.price_item.is_default == false}.size > 0
        total_extra = item_list.select{|x| x.price_item.is_default == false}.map{|x| x.item_price * x.quantity}.sum
      end
      # Add VAT on total_price & total_extra
      # total_prices += total_prices*Invoice::VAT/100
      # total_extra += total_extra*Invoice::VAT/100
      puts "Case 1"
      discount = get_discount(total_prices)
      puts "total_prices = #{total_prices-discount}"
      puts "discount = #{discount.inspect}"
      if self.total_prices != total_prices || self.total_extra != total_extra
        # self.update_attributes(total_prices: total_prices-discount, total_extra: total_extra, vat: vat)
        self.update_attributes(total_prices: total_prices-discount, total_extra: total_extra, discount: discount)
      end
    else
      # self.update_attributes(total_prices: total_prices, total_extra: total_extra, vat: vat)
      total_prices += self.appointment.appointment_fee if self.appointment.appointment_fee.present?
      total_prices += self.appointment.get_extra_fee if self.appointment.get_extra_fee > 0
      puts "Case 2"
      discount = get_discount(total_prices)
      puts "total_prices = #{total_prices}"
      puts "discount = #{discount.inspect}"
      self.update_attributes(total_prices: total_prices-discount, total_extra: total_extra, discount: discount)
    end
  end

  def as_json
    {
      uid: self.id,
      appointment_id: self.appointment_id,
      total_extra: number_to_currency(self.total_extra.to_f, precision: 2, unit: "", separator: ".", delimiter: ","),
      total_prices: number_to_currency(self.total_prices.to_f, precision: 2, unit: "", separator: ".", delimiter: ","),
      appointment_fee: self.appointment.try(:appointment_fee),
      # vat: "#{Invoice::VAT}%",
      created_at: "#{created_at.try(:strftime, '%B %d, %Y').upcase} AT #{created_at.try(:strftime, '%H:%M')}"
    }
  end
  
  def update_status
    transaction_payment = self.appointment.judo_transactions.select{|tran| tran.Payment?}.last
    if transaction_payment.present? && transaction_payment.Success?
      self.status = "closed"
    else
      self.status = "pending"
    end
  end

  def get_discount(total_prices)
    # Get voucher code to discount
    appointment = self.appointment
    voucher = appointment.try(:voucher)
    patient = appointment.try(:patient)
    if voucher.present?
      if voucher.is_percentage?
        discount_value = voucher.try(:amount).to_f
        discount = total_prices * (discount_value / 100)
      else
        discount = voucher.try(:amount).to_f
      end

      if voucher.type == 'ReferralCode'
        referral_info = voucher.referral_infos.where(referred_user_id: patient.try(:id)).first if patient.present?
        referral_info.update_attributes(was_bonused: true) if referral_info.present?
      end
    else
      if patient.present?
        credits = patient.credits.where(is_used: false).where("expired_date >= ? ", Time.now.to_date)
        discount = credits.sum(:credit_number).to_f
        credits.each do |credit|
          Credit.update_used_credits(patient.id, appointment.id)
        end
      end
    end
    discount
  end

  def make_payment_for_invoice
    if self.appointment.complete?
      if self.appointment.paymentable_type == 'PatientCreditPayment'
        res = self.appointment.make_payment({method: "payments", amount: self.total_prices.to_f.round(2)})
        self.update_columns(status: Invoice.statuses["closed"]) if res
      else
        # Collection captured payment(appointment fee)
        captured_payment = PaypalTransaction.find_by(appointment_id: self.appointment_id, payment_type: PaypalTransaction.payment_types[:capture], amount: self.appointment.appointment_fee)
        refresh_token = PatientPaypalPayment.find_by(id: self.appointment.paymentable_id).refresh_token
        access_token = PaypalPayment.get_access_token(refresh_token)
        collecttion_response = PaypalPayment.final_capture_payment(captured_payment.authorization_id, access_token, self.appointment.appointment_fee, is_final=false)
        puts "====================="
        puts "collecttion_response = #{collecttion_response.inspect}"
        puts "====================="
        if collecttion_response[:success]
          self.appointment.paypal_transactions.create({ status: PaypalTransaction.statuses["#{collecttion_response[:status]}"], amount: collecttion_response[:amount], currency: collecttion_response[:currency], 
                                                        description: PaypalTransaction::ON_COMPLETE, payment_id: collecttion_response[:payment_id], payment_type: PaypalTransaction.payment_types[:collection]
                                                      })
          # Payment remaining fee
          remaining_fee = self.total_prices.to_f - self.appointment.appointment_fee.to_f
          if remaining_fee > 0
            res = self.appointment.patient.execute_paypal_payment(remaining_fee)
            puts "====================="
            puts "res = #{res.inspect}"
            puts "====================="
            if res[:success]
              self.appointment.paypal_transactions.create({ status: PaypalTransaction.statuses["#{res[:status]}"], amount: res[:amount], currency: res[:currency], 
                                                            description: PaypalTransaction::ON_COMPLETE, payment_id: res[:payment_id], payment_type: PaypalTransaction.payment_types[:payment]
                                                          })
              self.update_columns(status: Invoice.statuses["closed"])
            end
          else
            puts "================"
            puts "remaining_fee <= 0"
            puts "================"
            self.update_columns(status: Invoice.statuses["closed"])
          end
        end
      end
    end
  end
end