module Api
  module V1
    class MeController < BaseController
      def show
        render json: { data: serialize_user(current_user) }
      end
    end
  end
end
