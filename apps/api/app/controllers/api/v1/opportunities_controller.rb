module Api
  module V1
    class OpportunitiesController < BaseController
      before_action -> { require_role!(:admin, :advisor) }, only: %i[create update destroy]

      def index
        relation = organization_scope(current_user.organization.opportunities).includes(:client, :owner_user).order(expected_close_date: :asc, created_at: :desc)
        relation = relation.where(stage: params[:stage]) if Opportunity.stages.key?(params[:stage].to_s)
        relation = relation.where(owner_user_id: params[:owner_user_id]) if params[:owner_user_id].present?
        records, meta = pagination(relation)
        render json: { data: records.map { |opportunity| serialize_opportunity(opportunity) }, meta: meta }
      end

      def show
        render json: { data: serialize_opportunity(find_opportunity) }
      end

      def create
        opportunity = current_user.organization.opportunities.new(opportunity_params)
        return render_validation_error(opportunity) unless opportunity.save

        audit!("opportunity.created", opportunity)
        render json: { data: serialize_opportunity(opportunity) }, status: :created
      end

      def update
        opportunity = find_opportunity
        return render_validation_error(opportunity) unless opportunity.update(opportunity_params)

        audit!("opportunity.updated", opportunity, changed: opportunity.saved_changes.keys)
        render json: { data: serialize_opportunity(opportunity) }
      end

      def destroy
        opportunity = find_opportunity
        opportunity.destroy!
        audit!("opportunity.deleted", opportunity)
        head :no_content
      end

      private

      def find_opportunity
        current_user.organization.opportunities.find(params[:id])
      end

      def opportunity_params
        params.permit(:client_id, :owner_user_id, :title, :stage, :estimated_value, :expected_close_date)
      end
    end
  end
end
