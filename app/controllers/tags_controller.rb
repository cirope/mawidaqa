class TagsController < ApplicationController
  before_filter :authenticate_user!
  
  check_authorization
  load_and_authorize_resource
  
  def index
    @tags = @tags.all_by_name(params[:q]).order('name ASC').limit(10)
    
    respond_to do |format|
      format.json { render json: @tags }
    end
  end
end
