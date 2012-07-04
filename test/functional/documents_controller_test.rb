require 'test_helper'

class DocumentsControllerTest < ActionController::TestCase
  setup do
    @document = Fabricate(:document)
  end

  test 'should get index' do
    sign_in Fabricate(:user)
    
    get :index
    assert_response :success
    assert_not_nil assigns(:documents)
    assert_select '#unexpected_error', false
    assert_template 'documents/index'
  end
  
  test 'should get filtered index' do
    sign_in Fabricate(:user)
    
    Fabricate(:document, name: 'excluded_from_filter')
    3.times { Fabricate(:document, name: 'in_filtered_index') }
    
    get :index, q: 'filtered_index'
    assert_response :success
    assert_not_nil assigns(:documents)
    assert_equal 3, assigns(:documents).size
    assert assigns(:documents).all? { |d| d.to_s =~ /filtered_index/ }
    assert_not_equal assigns(:documents).size, Document.count
    assert_select '#unexpected_error', false
    assert_template 'documents/index'
  end
  
  test 'get index with tag' do
    tag_with = Fabricate(:tag)
    tag_without = Fabricate(:tag)
    
    3.times { Fabricate(:document) { tags(count: 1) { tag_with } } }
    Fabricate(:document)
    
    sign_in Fabricate(:user)
    
    get :index, tag_id: tag_with.to_param
    assert_response :success
    assert_not_nil assigns(:documents)
    assert_equal 3, assigns(:documents).size
    assert assigns(:documents).all? { |d| d.tags.include?(tag_with) }
    assert_not_equal assigns(:documents).size, Document.count
    assert_select '#unexpected_error', false
    assert_template 'documents/index'
    
    get :index, tag_id: tag_without.to_param
    assert_response :success
    assert_not_nil assigns(:documents)
    assert_equal 0, assigns(:documents).size
    assert_select '#unexpected_error', false
    assert_template 'documents/index'
  end

  test 'should get new' do
    sign_in Fabricate(:user)
    
    get :new
    assert_response :success
    assert_not_nil assigns(:document)
    assert_select '#unexpected_error', false
    assert_template 'documents/new'
  end

  test 'should create document' do
    sign_in Fabricate(:user)
    
    assert_difference('Document.count') do
      post :create, document: Fabricate.attributes_for(:document)
    end

    assert_redirected_to document_url(assigns(:document))
  end

  test 'should show document' do
    sign_in Fabricate(:user)
    
    get :show, id: @document
    assert_response :success
    assert_not_nil assigns(:document)
    assert_select '#unexpected_error', false
    assert_template 'documents/show'
  end
  
  test 'should show document with relations' do
    sign_in Fabricate(:user)
    
    @document = Fabricate(:document_with_relations)
    
    get :show, id: @document
    assert_response :success
    assert_not_nil assigns(:document)
    assert_select '#unexpected_error', false
    assert_template 'documents/show'
  end

  test 'should get edit' do
    sign_in Fabricate(:user)
    
    get :edit, id: @document
    assert_response :success
    assert_not_nil assigns(:document)
    assert_select '#unexpected_error', false
    assert_template 'documents/edit'
  end

  test 'should update document' do
    sign_in Fabricate(:user)
    
    assert_no_difference 'Document.count' do
      put :update, id: @document, document: Fabricate.attributes_for(
        :document, name: 'Upd'
      )
    end
    
    assert_redirected_to document_path(assigns(:document))
    assert_equal 'Upd', @document.reload.name
  end

  test 'should destroy document' do
    sign_in Fabricate(:user)
    
    assert_difference('Document.count', -1) do
      delete :destroy, id: @document
    end

    assert_redirected_to documents_path
  end
  
  test 'should approve document' do
    sign_in Fabricate(:user)
    
    document = Fabricate(:document)
    
    assert document.revise!
    
    put :approve, id: document
    
    assert_redirected_to document_path(document)
    assert document.reload.approved?
  end
  
  test 'should not approve document if is not allowed to' do
    sign_in Fabricate(:user) {
      roles { User.valid_roles.map(&:to_s) - ['approver', 'admin'] }
    }
    
    document = Fabricate(:document)
    
    assert document.revise!
    
    put :approve, id: document
    
    assert_redirected_to root_path
    assert !document.reload.approved?
  end
  
  test 'should revise document' do
    sign_in Fabricate(:user)
    
    document = Fabricate(:document)
    
    put :revise, id: document
    
    assert_redirected_to document_path(document)
    assert document.reload.revised?
  end
  
  test 'should not revise document if is not allowed to' do
    sign_in Fabricate(:user) {
      roles { User.valid_roles.map(&:to_s) - ['reviewer', 'admin'] }
    }
    
    document = Fabricate(:document)
    
    put :revise, id: document
    
    assert_redirected_to root_path
    assert !document.reload.revised?
  end
  
  test 'should reject document' do
    sign_in Fabricate(:user)
    
    document = Fabricate(:document)
    
    put :reject, id: document
    
    assert_redirected_to document_path(document)
    assert document.reload.rejected?
  end
  
  test 'should not reject document if is not allowed to' do
    sign_in Fabricate(:user, role: :regular)
    
    document = Fabricate(:document)
    
    put :reject, id: document
    
    assert_redirected_to root_path
    assert !document.reload.rejected?
  end
  
  test 'should get create revision' do
    sign_in Fabricate(:user)
    @document = Fabricate(:document, status: 'approved')
    
    get :create_revision, id: @document
    assert_response :success
    assert_not_nil assigns(:document)
    assert_select '#unexpected_error', false
    assert_template 'documents/new'
  end
  
  test 'should get _create_ revision from existing revision' do
    sign_in Fabricate(:user)
    @document = Fabricate(:document, status: 'approved')
    new_revision = Document.on_revision_with_parent(@document.id)
    
    assert new_revision.new_record?
    assert new_revision.save
    
    get :create_revision, id: @document
    assert_response :success
    assert_not_nil assigns(:document)
    assert_select '#unexpected_error', false
    assert_template 'documents/edit'
  end
end
