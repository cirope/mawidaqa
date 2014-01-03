class ApplicationController < ActionController::Base
  include Application::CancanStrongParameters

  protect_from_forgery

  before_action :set_current_organization
  after_filter -> { expires_now if user_signed_in? }

  helper_method :current_organization

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: t('errors.access_denied')
  end

  def user_for_paper_trail
    current_user.try(:id)
  end

  def current_ability
    @_current_ability ||= Ability.new(current_user, current_organization)
  end

  def current_organization
    @_current_organization
  end

  def not_found
    redirect_to root_url
  end

  private

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def after_sign_in_path_for(resource)
    return_url = session[:user_return_to]

    if return_url.present?
      return_url
    else
      if resource.is?(:admin)
        organizations_url
      else
        count = resource.organizations.count
        if count > 1
          launchpad_url
        elsif count == 1
          dashboard_url(subdomain: resource.organizations.first.identification)
        else
          dashboard_url
        end
      end
    end
  end

  def set_current_organization
    unless RESERVED_SUBDOMAINS.include?(request.subdomains.first)
      @_current_organization ||= Organization.find_by_identification(
        request.subdomains.first
      )
    end
  end
end
