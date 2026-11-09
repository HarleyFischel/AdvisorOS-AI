module Api
  module V1
    class BaseController < ApplicationController
      before_action :require_authentication

      private

      def serialize_user(user)
        { id: user.id, email: user.email, full_name: user.full_name, role: user.role, organization: { id: user.organization_id, name: user.organization.name } }
      end

      def serialize_household(household)
        { id: household.id, name: household.name, description: household.description, client_count: household.clients.size, created_at: household.created_at, updated_at: household.updated_at }
      end

      def serialize_client(client)
        { id: client.id, first_name: client.first_name, last_name: client.last_name, full_name: client.full_name, email: client.email, phone: client.phone, status: client.status, estimated_aum: client.estimated_aum, household: client.household && { id: client.household.id, name: client.household.name }, assigned_user: client.assigned_user && { id: client.assigned_user.id, full_name: client.assigned_user.full_name }, created_at: client.created_at, updated_at: client.updated_at }
      end

      def serialize_opportunity(opportunity)
        { id: opportunity.id, title: opportunity.title, stage: opportunity.stage, estimated_value: opportunity.estimated_value, expected_close_date: opportunity.expected_close_date, client: { id: opportunity.client.id, full_name: opportunity.client.full_name }, owner: { id: opportunity.owner_user.id, full_name: opportunity.owner_user.full_name }, created_at: opportunity.created_at, updated_at: opportunity.updated_at }
      end

      def serialize_activity(activity)
        { id: activity.id, activity_type: activity.activity_type, summary: activity.summary, occurred_at: activity.occurred_at, user: { id: activity.user.id, full_name: activity.user.full_name }, client: { id: activity.client.id, full_name: activity.client.full_name } }
      end
    end
  end
end
