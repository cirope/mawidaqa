class OrganizationsController < ApplicationController
  before_filter :authenticate_user!

  check_authorization
  load_and_authorize_resource

  # GET /organizations
  # GET /organizations.json
  def index
    @title = t 'view.organizations.index_title'
    @searchable = true
    @organizations = @organizations.filtered_list(params[:q]).page(params[:page]).uniq('id')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @organizations }
    end
  end

  # GET /organizations/1
  # GET /organizations/1.json
  def show
    @title = t 'view.organizations.show_title'

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @organization }
    end
  end

  # GET /organizations/new
  # GET /organizations/new.json
  def new
    @title = t 'view.organizations.new_title'

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @organization }
    end
  end

  # GET /organizations/1/edit
  def edit
    @title = t 'view.organizations.edit_title'
  end

  # POST /organizations
  # POST /organizations.json
  def create
    @title = t 'view.organizations.new_title'

    respond_to do |format|
      if @organization.save
        format.html { redirect_to @organization, notice: t('view.organizations.correctly_created') }
        format.json { render json: @organization, status: :created, location: @organization }
      else
        format.html { render action: 'new' }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /organizations/1
  # PATCH /organizations/1.json
  def update
    @title = t 'view.organizations.edit_title'

    respond_to do |format|
      if @organization.update(organization_params)
        format.html { redirect_to @organization, notice: t('view.organizations.correctly_updated') }
        format.json { head :ok }
      else
        format.html { render action: 'edit' }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end

  rescue ActiveRecord::StaleObjectError
    redirect_to edit_organization_url(@organization), alert: t('view.organizations.stale_object_error')
  end

  # DELETE /organizations/1
  # DELETE /organizations/1.json
  def destroy
    @organization.destroy

    respond_to do |format|
      format.html { redirect_to organizations_url }
      format.json { head :ok }
    end
  end

  private

    def organization_params
      params.require(:organization).permit(:name, :identification, :lock_version)
    end
end
