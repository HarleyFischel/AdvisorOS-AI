require "rails_helper"

RSpec.describe LoginRateLimiter do
  let(:key) { "spec-login-rate-limit" }

  before { described_class.reset(key) }
  after { described_class.reset(key) }

  it "persists the shared attempt window and blocks after the limit" do
    LoginRateLimiter::LIMIT.times { expect(described_class.allow?(key)).to be(true) }
    expect(described_class.allow?(key)).to be(false)
    expect(LoginRateLimit.find_by(key: key).attempts).to eq(LoginRateLimiter::LIMIT)
  end

  it "clears a successful login's failed-attempt window" do
    2.times { described_class.allow?(key) }
    described_class.reset(key)
    expect(described_class.allow?(key)).to be(true)
    expect(LoginRateLimit.find_by(key: key).attempts).to eq(1)
  end
end
