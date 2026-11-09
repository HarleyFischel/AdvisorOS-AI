module Api
  module V1
    class ClientsController < BaseController
      before_action -> { require_role!(:admin, :advisor) }, only: %i[create update destroy]

      def index
        relation = organization_scope(current_user.organization.clients).includes(:household, :assigned_user)
        if params[:q].present?
          query = "%#{ActiveRecord::Base.sanitize_sql_like(params[:q].to_s)}%"
          relation = relation.where("first_name ILIKE :q OR last_name ILIKE :q OR email ILIKE :q", q: query)
        end
        relation = relation.where(status: params[:status]) if Client.statuses.key?(params[:status].to_s)
        relation = relation.order(sort_column => sort_direction)
        records, meta = pagination(relation)
        render json: { data: records.map { |client| serialize_client(client) }, meta: meta }
      end

      def show
        client = find_client
        render json: { data: serialize_client(client), activities: client.activities.order(occurred_at: :desc).limit(25).map { |activity| serialize_activity(activity) } }
      end

      def create
        client = current_user.organization.clients.new(client_params)
        return render_validation_error(client) unless client.save

        audit!("client.created", client)
        render json: { data: serialize_client(client) }, status: :created
      end

      def update
        client = find_client
        return render_validation_error(client) unless client.update(client_params)

        audit!("client.updated", client, changed: client.saved_changes.keys)
        render json: { data: serialize_client(client) }
      end

      def destroy
        client = find_client
        return render_error("Clients with opportunities or activities cannot be deleted", :unprocessable_entity) if client.opportunities.exists? || client.activities.exists?

        client.destroy!
        audit!("client.deleted", client)
        head :no_content
      end

      private

      def find_client
        current_user.organization.clients.find(params[:id])
      end

      def client_params
        params.permit(:first_name, :last_name, :email, :phone, :status, :estimated_aum, :household_id, :assigned_user_id)
      end

      def sort_column
        %w[first_name last_name estimated_aum created_at].include?(params[:sort]) ? params[:sort] : "last_name"
      end

      def sort_direction
        params[:direction].to_s.downcase == "desc" ? :desc : :asc
      end
    end
  end
end
