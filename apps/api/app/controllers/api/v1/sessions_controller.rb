module Api
  module V1
    class SessionsController < ApplicationController
      def csrf
        render json: { csrf_token: form_authenticity_token }
      end

      def create
        email = params[:email].to_s.strip.downcase
        return render_error("Invalid email or password", :unauthorized) unless LoginRateLimiter.allow?(request.remote_ip)

        user = User.find_by(email: email)
        if user&.authenticate(params[:password].to_s)
          LoginRateLimiter.reset(request.remote_ip)
          reset_session
          session[:user_id] = user.id
          render json: { data: { user: { id: user.id, email: user.email, full_name: user.full_name, role: user.role, organization: { id: user.organization_id, name: user.organization.name } } } }
        else
          render_error("Invalid email or password", :unauthorized)
        end
      end

      def destroy
        reset_session
        head :no_content
      end
    end
  end
end
