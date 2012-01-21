class DocumentsController < ApplicationController
  before_filter :authenticate_user!
  
  check_authorization
  load_and_authorize_resource
  
  # GET /documents
  # GET /documents.json
  def index
    @title = t 'view.documents.index_title'
    @documents = @documents.ordered_list.paginate(
      page: params[:page], per_page: LINES_PER_PAGE
    )

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
      if @document.update_attributes(params[:document])
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
end
