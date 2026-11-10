module Api
  module V1
    class HouseholdsController < BaseController
      before_action -> { require_role!(:admin, :advisor) }, only: %i[create update destroy]

      def index
        relation = organization_scope(current_user.organization.households).includes(:clients).order(sort_column => sort_direction)
        relation = relation.where("name ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(params[:q].to_s)}%") if params[:q].present?
        records, meta = pagination(relation)
        render json: { data: records.map { |household| serialize_household(household) }, meta: meta }
      end

      def show
        render json: { data: serialize_household(find_household) }
      end

      def create
        household = current_user.organization.households.new(household_params)
        return render_validation_error(household) unless household.save

        audit!("household.created", household)
        render json: { data: serialize_household(household) }, status: :created
      end

      def update
        household = find_household
        return render_validation_error(household) unless household.update(household_params)

        audit!("household.updated", household, changed: household.saved_changes.keys)
        render json: { data: serialize_household(household) }
      end

      def destroy
        household = find_household
        return render_error("Households with clients cannot be deleted", :unprocessable_content) if household.clients.exists?

        household.destroy!
        audit!("household.deleted", household)
        head :no_content
      end

      private

      def find_household
        current_user.organization.households.find(params[:id])
      end

      def household_params
        params.permit(:name, :description)
      end

      def sort_column
        %w[name created_at updated_at].include?(params[:sort]) ? params[:sort] : "name"
      end

      def sort_direction
        params[:direction].to_s.downcase == "desc" ? :desc : :asc
      end
    end
  end
end
