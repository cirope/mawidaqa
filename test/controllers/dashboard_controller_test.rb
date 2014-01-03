require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  setup do
    organization = Fabricate(:organization)
    user = Fabricate(:user, password: '123456', roles: [:normal])
    @job = Fabricate(:job, user_id: user.id, organization_id: organization.id)
    @request.host = "#{organization.identification}.lvh.me"

    sign_in user
  end

  test "should get index" do
    get :index
    assert_redirected_to action: @job.job
  end

  test 'should get approver dashboard' do
    assert @job.update_attribute :job, 'approver'
    get :approver
    assert_response :success
    assert_template 'dashboard/greetings'
  end

  test 'should get reviewer dashboard' do
    assert @job.update_attribute :job, 'reviewer'
    get :reviewer
    assert_response :success
    assert_template 'dashboard/greetings'
  end

  test 'should get author dashboard' do
    assert @job.update_attribute :job, 'author'
    get :author
    assert_response :success
    assert_template 'dashboard/greetings'
  end
end
