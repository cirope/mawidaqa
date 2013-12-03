class DocumentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_tag, only: [:index]
  before_filter :new_document_with_parent, only: [:create_revision]

  check_authorization
  load_and_authorize_resource through: :current_organization

  # GET /documents
  # GET /documents.json
  def index
    @title = t 'view.documents.index_title'
    @searchable = true
    @documents = @documents.filtered_list(params[:q]).page(params[:page]).uniq('id')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @documents }
    end
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
    @title = t 'view.documents.show_title'

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @document }
    end
  end

  # GET /documents/new
  # GET /documents/new.json
  def new
    @title = t 'view.documents.new_title'

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @document }
    end
  end

  # GET /documents/1/edit
  def edit
    @title = t 'view.documents.edit_title'
  end

  # POST /documents
  # POST /documents.json
  def create
    @title = t 'view.documents.new_title'

    respond_to do |format|
      if @document.save
        format.html { redirect_to @document, notice: t('view.documents.correctly_created') }
        format.json { render json: @document, status: :created, location: @document }
      else
        format.html { render action: 'new' }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /documents/1
  # PUT /documents/1.json
  def update
    @title = t 'view.documents.edit_title'

    respond_to do |format|
      if @document.update(document_params)
        format.html { redirect_to @document, notice: t('view.documents.correctly_updated') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end

  rescue ActiveRecord::StaleObjectError
    flash.alert = t 'view.documents.stale_object_error'
    redirect_to edit_document_url(@document)
  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    @document.destroy

    respond_to do |format|
      format.html { redirect_to documents_url }
      format.json { head :no_content }
    end
  end

  # PUT /documents/1/approve
  # PUT /documents/1/approve.json
  def approve
    @document.approve!

    respond_to do |format|
      format.html { redirect_to @document, notice: t('view.documents.approved') }
      format.json { head :no_content }
    end
  end

  # PUT /documents/1/revise
  # PUT /documents/1/revise.json
  def revise
    @document.revise!

    respond_to do |format|
      format.html { redirect_to @document, notice: t('view.documents.revised') }
      format.json { head :no_content }
    end
  end

  # PUT /documents/1/reject
  # PUT /documents/1/reject.json
  def reject
    @document.reject!

    respond_to do |format|
      format.html { redirect_to @document, notice: t('view.documents.rejected') }
      format.json { head :no_content }
    end
  end

  # GET /documents/1/create_revision
  # GET /documents/1/create_revision.json
  def create_revision
    @title = t 'view.documents.new_title'

    respond_to do |format|
      format.html { render action: (@document.new_record? ? 'new' : 'edit') }
      format.json { render json: @document }
    end
  end

  private
    def document_params
      params.require(:document).permit(
        :name, :code, :version, :notes, :version_comments, :kind, :tag_list,
        :parent_id, :organization_id, :lock_version,
        comments_attributes: [:id, :content, :commentable_id, :lock_version],
        changes_attributes: [:id, :content, :made_at, :document_id, :lock_version]
      )
    end

    def load_tag
      @tag = Tag.find(params[:tag_id]) if params[:tag_id].present?
      @documents = current_organization.tags.find(@tag).documents if @tag
    end

    def new_document_with_parent
      @document = Document.on_revision_with_parent(params[:id])
    end
end
