class LaunchpadController < ApplicationController
  before_filter :authenticate_user!

  def index
    @title = t 'view.launchpad.index_title'
    @organizations = current_user.organizations
            
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @organizations }
    end
  end
end
