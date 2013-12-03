class TagsController < ApplicationController
  before_filter :authenticate_user!

  check_authorization
  load_and_authorize_resource through: :current_organization

  def index
    @tags = @tags.where("#{Tag.table_name}.name ILIKE ?", "#{params[:q]}%").limit(10)

    respond_to do |format|
      format.json { render json: @tags }
    end
  end
end
