class LoginRateLimiter
  LIMIT = 10
  WINDOW = 15.minutes

  def self.allow?(key)
    now = Time.current
    LoginRateLimit.transaction do
      limiter = LoginRateLimit.lock.find_or_initialize_by(key: key)
      if limiter.new_record? || limiter.window_started_at <= now - WINDOW
        limiter.assign_attributes(window_started_at: now, attempts: 1)
        limiter.save!
        true
      elsif limiter.attempts >= LIMIT
        false
      else
        limiter.increment!(:attempts)
        true
      end
    end
  end

  def self.reset(key)
    LoginRateLimit.where(key: key).delete_all
  end
end
