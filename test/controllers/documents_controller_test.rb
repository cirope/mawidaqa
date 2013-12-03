require 'test_helper'

class DocumentsControllerTest < ActionController::TestCase
  setup do
    @organization = Fabricate(:organization)
    @document = Fabricate(:document, organization_id: @organization.id)
    @user = Fabricate(:user, role: :regular)
    job = Fabricate(
      :job, job: 'author', user_id: @user.id, organization_id: @organization.id
    )
    @request.host = "#{@organization.identification}.lvh.me"

    sign_in @user
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:documents)
    assert_select '#unexpected_error', false
    assert_template 'documents/index'
  end

  test 'should get filtered index' do
    Fabricate(:document, name: 'excluded_from_filter', organization_id: @organization.id)
    3.times { Fabricate(:document, name: 'in_filtered_index', organization_id: @organization.id) }

    get :index, q: 'filtered_index'
    assert_response :success
    assert_not_nil assigns(:documents)
    assert_equal 3, assigns(:documents).size
    assert assigns(:documents).all? { |d| d.to_s =~ /filtered_index/ }
    assert_not_equal assigns(:documents).size, @organization.documents.count
    assert_select '#unexpected_error', false
    assert_template 'documents/index'
  end

  test 'get index with tag' do
    user = Fabricate(:user, role: :regular)
    job = Fabricate(
      :job, job: 'author', user_id: user.id, organization_id: @organization.id
    )
    sign_in user

    tag_with = Fabricate(:tag, organization_id: @organization.id)
    tag_without = Fabricate(:tag, organization_id: @organization.id)

    3.times { Fabricate(:document, organization_id: @organization.id) { tags(count: 1) { tag_with } } }

    get :index, tag_id: tag_with.to_param
    assert_response :success
    assert_not_nil assigns(:documents)
    assert_equal 3, assigns(:documents).size
    assert assigns(:documents).all? { |d| d.tags.include?(tag_with) }
    assert_not_equal assigns(:documents).size, @organization.documents.count
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
    sign_in @user

    get :new
    assert_response :success
    assert_not_nil assigns(:document)
    assert_select '#unexpected_error', false
    assert_template 'documents/new'
  end

  test 'should create document' do
    sign_in @user

    assert_difference('Document.count') do
      post :create, document: Fabricate.attributes_for(:document)
    end

    assert_redirected_to document_url(assigns(:document))
  end

  test 'should show document' do
    sign_in @user

    get :show, id: @document
    assert_response :success
    assert_not_nil assigns(:document)
    assert_select '#unexpected_error', false
    assert_template 'documents/show'
  end

  test 'should show document with relations' do
    user = Fabricate(:user, role: :regular)
    job = Fabricate(
      :job, job: 'author', user_id: user.id, organization_id: @organization.id
    )
    sign_in user

    @document = Fabricate(:document_with_relations, organization_id: @organization.id)

    get :show, id: @document
    assert_response :success
    assert_not_nil assigns(:document)
    assert_select '#unexpected_error', false
    assert_template 'documents/show'
  end

  test 'should get edit' do
    sign_in @user

    get :edit, id: @document
    assert_response :success
    assert_not_nil assigns(:document)
    assert_select '#unexpected_error', false
    assert_template 'documents/edit'
  end

  test 'should update document' do
    sign_in @user

    assert_no_difference 'Document.count' do
      put :update, id: @document, document: Fabricate.attributes_for(
        :document, name: 'Upd', organization_id: @organization.id
      )
    end

    assert_redirected_to document_path(assigns(:document))
    assert_equal 'Upd', @document.reload.name
  end

  test 'should destroy document' do
    sign_in @user

    assert_difference('Document.count', -1) do
      delete :destroy, id: @document
    end

    assert_redirected_to documents_path
  end

  test 'should approve document' do
    user = Fabricate(:user, role: :regular)
    job = Fabricate(
      :job, job: 'approver', user_id: user.id, organization_id: @organization.id
    )
    sign_in user

    document = Fabricate(:document, organization_id: @organization.id)

    assert document.revise!

    put :approve, id: document

    assert_redirected_to document_path(document)
    assert document.reload.approved?
  end

  test 'should not approve document if is not allowed to' do
    user = Fabricate(:user, role: :regular)
    job = Fabricate(
      :job, job: 'author', user_id: user.id, organization_id: @organization.id
    )
    sign_in user

    document = Fabricate(:document, organization_id: @organization.id)

    assert document.revise!

    put :approve, id: document

    assert_redirected_to root_path
    assert !document.reload.approved?
  end

  test 'should revise document' do
    user = Fabricate(:user, role: :regular)
    job = Fabricate(
      :job, job: 'reviewer', user_id: user.id, organization_id: @organization.id
    )
    sign_in user

    document = Fabricate(:document, organization_id: @organization.id)

    put :revise, id: document

    assert_redirected_to document_path(document)
    assert document.reload.revised?
  end

  test 'should not revise document if is not allowed to' do
    user = Fabricate(:user, role: :regular)
    job = Fabricate(
      :job, job: 'author', user_id: user.id, organization_id: @organization.id
    )
    sign_in user

    document = Fabricate(:document, organization_id: @organization.id)

    put :revise, id: document

    assert_redirected_to root_path
    assert !document.reload.revised?
  end

  test 'should reject document' do
    user = Fabricate(:user, role: :regular)
    job = Fabricate(
      :job, job: 'approver', user_id: user.id, organization_id: @organization.id
    )
    sign_in user

    document = Fabricate(:document, status: 'revised', organization_id: @organization.id)

    put :reject, id: document

    assert_redirected_to document_path(document)
    assert document.reload.on_revision?
  end

  test 'should not reject document if is not allowed to' do
    user = Fabricate(:user, role: :regular)
    job = Fabricate(
      :job, job: 'author', user_id: user.id, organization_id: @organization.id
    )
    sign_in user

    document = Fabricate(:document, status: 'revised', organization_id: @organization.id)

    put :reject, id: document

    assert_redirected_to root_path
    assert !document.reload.on_revision?
  end

  test 'should get create revision' do
    user = Fabricate(:user, role: :regular)
    job = Fabricate(
      :job, job: 'reviewer', user_id: user.id, organization_id: @organization.id
    )
    sign_in user

    @document = Fabricate(:document, status: 'approved', organization_id: @organization.id)

    get :create_revision, id: @document
    assert_response :success
    assert_not_nil assigns(:document)
    assert_select '#unexpected_error', false
    assert_template 'documents/new'
  end

  test 'should get _create_ revision from existing revision' do
    user = Fabricate(:user, role: :regular)
    job = Fabricate(
      :job, job: 'reviewer', user_id: user.id, organization_id: @organization.id
    )
    sign_in user

    @document = Fabricate(:document, status: 'approved', organization_id: @organization.id)
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
