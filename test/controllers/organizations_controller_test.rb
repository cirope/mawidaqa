require 'test_helper'

class OrganizationsControllerTest < ActionController::TestCase
  setup do
    @organization = Fabricate(:organization)

    sign_in Fabricate(:user)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:organizations)
    assert_select '#unexpected_error', false
    assert_template "organizations/index"
  end

  test 'should get filtered index' do
    3.times { Fabricate(:organization, name: 'in_filtered_index') }

    get :index, q: 'filtered_index'
    assert_response :success
    assert_not_nil assigns(:organizations)
    assert_equal 3, assigns(:organizations).size
    assert assigns(:organizations).all? { |s| s.inspect =~ /filtered_index/ }
    assert_not_equal assigns(:organizations).size, Organization.count
    assert_select '#unexpected_error', false
    assert_template 'organizations/index'
  end

  test 'should get filtered index in json' do
    3.times { Fabricate(:organization, name: 'in_filtered_index') }

    get :index, q: 'filtered_index', format: 'json'
    assert_response :success

    organizations = ActiveSupport::JSON.decode(@response.body)

    assert_equal 3, organizations.size
    assert organizations.all? { |s| s['label'].match /filtered_index/i }

    get :index, q: 'no_organization', format: 'json'
    assert_response :success

    organizations = ActiveSupport::JSON.decode(@response.body)

    assert_equal 0, organizations.size
  end

  test "should get new" do
    get :new
    assert_response :success
    assert_not_nil assigns(:organization)
    assert_select '#unexpected_error', false
    assert_template "organizations/new"
  end

  test "should create organization" do
    assert_difference('Organization.count') do
      post :create, organization: Fabricate.attributes_for(:organization)
    end

    assert_redirected_to organization_url(assigns(:organization))
  end

  test "should show organization" do
    get :show, id: @organization
    assert_response :success
    assert_not_nil assigns(:organization)
    assert_select '#unexpected_error', false
    assert_template "organizations/show"
  end

  test "should get edit" do
    get :edit, id: @organization
    assert_response :success
    assert_not_nil assigns(:organization)
    assert_select '#unexpected_error', false
    assert_template "organizations/edit"
  end

  test "should update organization" do
    assert_no_difference 'Organization.count' do
      patch :update, id: @organization,
      organization: Fabricate.attributes_for(:organization, name: 'value')
    end

    assert_redirected_to organization_url(assigns(:organization))
    assert_equal 'value', @organization.reload.name
  end

  test "should destroy organization" do
    assert_difference('Organization.count', -1) do
      delete :destroy, id: @organization
    end

    assert_redirected_to organizations_path
  end
end
