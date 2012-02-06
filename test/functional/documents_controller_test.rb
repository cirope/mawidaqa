require 'test_helper'

class DocumentsControllerTest < ActionController::TestCase
  setup do
    @document = Fabricate(:document)
    
    sign_in Fabricate(:user)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:documents)
    assert_select '#unexpected_error', false
    assert_template 'documents/index'
  end

  test 'should get new' do
    get :new
    assert_response :success
    assert_not_nil assigns(:document)
    assert_select '#unexpected_error', false
    assert_template 'documents/new'
  end

  test 'should create document' do
    assert_difference('Document.count') do
      post :create, document: Fabricate.attributes_for(
        :document, file: fixture_file_upload('files/test.txt', 'text/plain')
      )
    end

    assert_redirected_to document_path(assigns(:document))
  end

  test 'should show document' do
    get :show, id: @document
    assert_response :success
    assert_not_nil assigns(:document)
    assert_select '#unexpected_error', false
    assert_template 'documents/show'
  end

  test 'should get edit' do
    get :edit, id: @document
    assert_response :success
    assert_not_nil assigns(:document)
    assert_select '#unexpected_error', false
    assert_template 'documents/edit'
  end

  test 'should update document' do
    assert_no_difference 'Document.count' do
      put :update, id: @document, document: Fabricate.attributes_for(
        :document, name: 'Upd'
      )
    end
    
    assert_redirected_to document_path(assigns(:document))
    assert_equal 'Upd', @document.reload.name
  end

  test 'should destroy document' do
    assert_difference('Document.count', -1) do
      delete :destroy, id: @document
    end

    assert_redirected_to documents_path
  end
end
