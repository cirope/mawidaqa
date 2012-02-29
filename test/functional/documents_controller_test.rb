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

  test 'should get new' do
    sign_in Fabricate(:user)
    
    get :new
    assert_response :success
    assert_not_nil assigns(:document)
    assert_select '#unexpected_error', false
    assert_template 'documents/new'
  end

# TODO: review this test in some point, there is a problem with carrier_wave and
# the validation of presence apparently. For now this is tested as an
# integration test
# 
#  test 'should create document' do
#  end

  test 'should show document' do
    sign_in Fabricate(:user)
    
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
    sign_in Fabricate(:user) {
      roles { User.valid_roles.map(&:to_s) - ['approver', 'admin'] }
    }
    
    document = Fabricate(:document)
    
    put :reject, id: document
    
    assert_redirected_to root_path
    assert !document.reload.rejected?
  end
end
