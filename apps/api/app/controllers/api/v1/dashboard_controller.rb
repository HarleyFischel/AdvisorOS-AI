module Api
  module V1
    class DashboardController < BaseController
      def show
        organization = current_user.organization
        clients = organization.clients
        opportunities = organization.opportunities
        activities = organization.activities.includes(:user, :client).order(occurred_at: :desc).limit(8)
        render json: { data: {
          metrics: {
            total_clients: clients.count,
            total_households: organization.households.count,
            total_estimated_aum: clients.sum(:estimated_aum),
            open_opportunities: opportunities.where.not(stage: %w[won lost]).count
          },
          pipeline_by_stage: Opportunity.stages.keys.index_with { |stage| { count: opportunities.where(stage: stage).count, value: opportunities.where(stage: stage).sum(:estimated_value) } },
          recent_activities: activities.map { |activity| serialize_activity(activity) },
          client_growth: (0..5).map { |months_ago| month = months_ago.months.ago.beginning_of_month; { month: month.strftime("%b %Y"), count: clients.where(created_at: month..month.end_of_month).count } }.reverse
        } }
      end
    end
  end
end
