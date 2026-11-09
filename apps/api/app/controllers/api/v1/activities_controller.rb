module Api
  module V1
    class ActivitiesController < BaseController
      before_action -> { require_role!(:admin, :advisor) }, only: :create

      def index
        client = current_user.organization.clients.find(params[:client_id])
        activities = client.activities.includes(:user).order(occurred_at: :desc)
        render json: { data: activities.limit(100).map { |activity| serialize_activity(activity) } }
      end

      def create
        client = current_user.organization.clients.find(params[:client_id])
        activity = client.activities.new(activity_params.merge(organization: current_user.organization, user: current_user))
        return render_validation_error(activity) unless activity.save

        audit!("activity.created", activity)
        render json: { data: serialize_activity(activity) }, status: :created
      end

      private

      def activity_params
        params.permit(:activity_type, :summary, :occurred_at)
      end
    end
  end
end
