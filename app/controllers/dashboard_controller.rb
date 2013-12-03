class DashboardController < ApplicationController
  before_filter :authenticate_user!, :load_organization_job, :validate_action
  respond_to :html, :json

  def index
    if @job
      flash.keep

      redirect_to action: @job.job
    else
      raise 'You have no job here =)'
    end
  end

  def approver
    @title = t 'view.dashboard.generic_title'
  end

  def reviewer
    @title = t 'view.dashboard.generic_title'
  end

  def author
    @title = t 'view.dashboard.generic_title'
  end

  private

  def load_organization_job
    @job = current_user.jobs.in_organization(current_organization).first
  end

  def validate_action
    raise 'You can not do this =)' if ['index', @job.job].exclude?(action_name)
  end
end
