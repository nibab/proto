class User < ActiveRecord::Base
  attr_accessor :activation_token, :reset_token
  before_create :create_activation_digest
  before_save { self.email = email.downcase }

  validates_length_of :recommending, maximum: 4 ## NO IDEA WHY IT ONLY STOPS VALIDATION AFTER ONE



  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "recommender_id"
  has_many :passive_relationships, class_name:  "Relationship",
                                  foreign_key: "recommended_id"
  has_many :prospect_invitations, class_name: "Prospect",
                                  foreign_key: "recommender_id"
  has_many :posts

  has_many :recommending, through: :active_relationships, source: :recommended
  has_many :recommenders, through: :passive_relationships, source: :recommender
  has_many :prospects, through: :prospect_invitations, source: :recommender

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :first, :last, :email, presence: true
  validates :first, :last, length: {maximum: 50}
  validates :email, length: {maximum: 255},
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false },
                    :reduce => true
  has_secure_password
  validates :password, length: { minimum: 6 }, presence: true, :reduce => true, allow_nil: true
  #validate :check_personal_code, :on => :create

  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
        BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Generates new token
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Activates an account.
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Updates the prospect table
  def update_prospect_table
    prospect = Prospect.where(pcode:self.pcode).first
    prospect.register
  end

  # Creates the password digest
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Sends the password_reset digest
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Validates if password reset still valid
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def check_personal_code
    prospect = Prospect.where(email:email.downcase).first
    #puts self.pcode
    #prospect = Prospect.where(pcode:self.pcode).first
    if !prospect
      errors.add(:email, "you haven't been granted access to the platform")
    end
    if !!prospect && (prospect.registered == true)
      errors.add(:email, "this email is already in use")
    end

  end

  private
  # Returns a random token.
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end

end
