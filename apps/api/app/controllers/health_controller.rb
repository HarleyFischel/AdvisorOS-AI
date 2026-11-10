class HealthController < ApplicationController
  skip_forgery_protection

  def show
    render json: { status: "ok", service: "advisoros-api", time: Time.current.iso8601 }
  end
end
