class User < ActiveRecord::Base
	belongs_to :referrer, class_name: "User", foreign_key: "referrer_id"
    has_many :referrals, class_name: "User", foreign_key: "referrer_id"
    

	validates :email, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: "Invalid email format.", on: :create }
	validates :referral_code, uniqueness: true

	include Tokenable
    #before_create :create_referral_code
    #after_create :send_welcome_email

    private

    def create_referral_code
        referral_code = SecureRandom.hex(5)
        @collision = User.find_by_referral_code(referral_code)

        while !@collision.nil?
            referral_code = SecureRandom.hex(5)
            @collision = User.find_by_referral_code(referral_code)
        end

        self.referral_code = referral_code
    end

    def send_welcome_email
        UserMailer.delay.signup_email(self)
    end
end
