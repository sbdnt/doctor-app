class Agency < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  # validates :name, presence: true, uniqueness: true
  # validates :address, presence: true
  # validates :phone_number, presence: true
  # validates :account_number, :bank_name, :branch_address, :sort_code, presence: true
  # validates :reason, presence: true, if: proc {|a| a.rejected?}
  enum role: {"GP" => 1, "Locum Agency" => 2, "Current GP Services Provider" => 3}
  enum gender: {"Female" => 1, "Male" => 2}
  before_save :generate_auth_token, :if => lambda {|a| a.email_changed?}

  # Relation
  has_many :doctors
  has_many :schedules

  #Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true
  validates :role, presence: true

  after_update :send_email_approved, if: proc{|a| a.status_changed?}
  enum status: {pending: 0, approved: 1, rejected: 2}
  scope :approved, -> { where(status: 1)}
  def self.modify_status
    {approved: 1, rejected: 2}
  end

  def name
    "#{last_name} #{first_name}"
  end

  def send_email_approved
    if self.approved?
      AgencyMailer.welcome_email(self).deliver_now
    elsif self.rejected?
      AgencyMailer.reject_agency(self).deliver_now
    end
  end

  def active_for_authentication?
    super && self.approved? # i.e. super && self.is_active
  end

  def inactive_message
    "Sorry, this account has not been approved!"
  end

  protected

  def generate_auth_token
    self.auth_token = SecureRandom.urlsafe_base64
    generate_auth_token if self.class.exists?(auth_token: self.auth_token)
  end
end
