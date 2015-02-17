module Tokenable
  extend ActiveSupport::Concern

  included do
    before_create :generate_token
  end

  protected

  def generate_token
    self.referral_code = loop do
      referralCode = SecureRandom.urlsafe_base64(nil, false)
      break referralCode unless self.class.exists?(referral_code: referralCode)
    end
  end
end