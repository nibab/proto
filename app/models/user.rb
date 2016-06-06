class User < ActiveRecord::Base
  attr_accessor :activation_token
  before_create :create_activation_digest
  before_save { self.email = email.downcase }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :first, :last, :email, presence: true
  validates :first, :last, length: {maximum: 50}
  validates :email, length: {maximum: 255},
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false },
                    :reduce => true
  has_secure_password
  validates :password, length: { minimum: 6 }, presence: true, :reduce => true, allow_nil: true

  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
        BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  private
  # Returns a random token.
    def User.new_token
      SecureRandom.urlsafe_base64
    end

    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end

    def authenticated?(attribute, token)
      digest = send("#{attribute}_digest")
      return false if digest.nil?
      BCrypt::Password.new(digest).is_password?(token)
    end

end
