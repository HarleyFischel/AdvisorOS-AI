class ApplicationController < ActionController::Base
  include ActionController::Cookies
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound do
    render_error("Resource not found", :not_found)
  end
  rescue_from ActionController::InvalidAuthenticityToken do
    render_error("Request could not be verified", :unprocessable_content)
  end

  helper_method :current_user

  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.includes(:organization).find_by(id: session[:user_id])
  end

  def require_authentication
    return if current_user

    render_error("Authentication required", :unauthorized)
  end

  def require_role!(*roles)
    return if current_user && roles.map(&:to_s).include?(current_user.role)

    render_error("You do not have permission to perform this action", :forbidden)
  end

  def organization_scope(relation)
    relation.where(organization_id: current_user.organization_id)
  end

  def render_error(message, status, details: nil)
    body = { error: { code: Rack::Utils.status_code(status), message: message } }
    body[:error][:details] = details if details
    render json: body, status: status
  end

  def render_validation_error(record)
    render_error("Validation failed", :unprocessable_content, details: record.errors.to_hash)
  end

  def pagination(relation)
    page = [params.fetch(:page, 1).to_i, 1].max
    per_page = [[params.fetch(:per_page, 20).to_i, 1].max, 100].min
    [relation.offset((page - 1) * per_page).limit(per_page), { page: page, per_page: per_page, total: relation.count }]
  end

  def audit!(action, record, metadata = {})
    AuditLogger.call(actor: current_user, action: action, record: record, metadata: metadata)
  end
end
