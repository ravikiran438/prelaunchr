class User < ActiveRecord::Base

	belongs_to :referrer, class_name: "User", foreign_key: "referrer_id"
    has_many :referrals, class_name: "User", foreign_key: "referrer_id"
    

	validates :email, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: "Invalid email format.", on: :create }
	validates :referral_code, uniqueness: true

    before_create :create_referral_code
    after_create :send_welcome_email
end
