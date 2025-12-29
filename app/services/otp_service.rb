class OtpService
  OTP_LENGTH = 6
  OTP_EXPIRY_MINUTES = 10

  def self.generate_otp
    rand(100000..999999).to_s
  end

  def self.send_otp(user)
    otp = generate_otp
    user.update!(
      otp: otp,
      otp_sent_at: Time.current
    )
    
    OtpMailer.send_otp(user, otp).deliver_now
    otp
  end

  def self.verify_otp(user, code)
    return false if user.otp.blank?
    return false if user.otp_sent_at.blank?
    return false if user.otp_sent_at < OTP_EXPIRY_MINUTES.minutes.ago
    
    if user.otp == code.to_s
      user.update!(
        is_verified: true,
        otp: nil,
        otp_sent_at: nil
      )
      true
    else
      false
    end
  end

  def self.resend_otp(user)
    send_otp(user)
  end
end

