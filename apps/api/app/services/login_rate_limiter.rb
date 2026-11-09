class LoginRateLimiter
  LIMIT = 10
  WINDOW = 15.minutes
  @mutex = Mutex.new
  @attempts = {}

  def self.allow?(key)
    now = Time.current.to_i
    @mutex.synchronize do
      @attempts[key] = @attempts.fetch(key, []).select { |timestamp| timestamp > now - WINDOW.to_i }
      return false if @attempts[key].length >= LIMIT

      @attempts[key] << now
      true
    end
  end

  def self.reset(key)
    @mutex.synchronize { @attempts.delete(key) }
  end
end
