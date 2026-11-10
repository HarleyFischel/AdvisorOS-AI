Rails.application.config.content_security_policy do |policy|
  policy.default_src :self
  policy.script_src :self, :unsafe_inline
  policy.style_src :self, :unsafe_inline
  policy.img_src :self, :data
  policy.connect_src :self, "http://localhost:3000", "http://localhost:5173"
end
