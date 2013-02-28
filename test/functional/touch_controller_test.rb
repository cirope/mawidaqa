require 'test_helper'

class TouchControllerTest < ActionController::TestCase

  setup do
    @organization = Fabricate(:organization)
    user = Fabricate(:user, role: :regular)
    job = Fabricate(
      :job, job: 'author', user_id: user.id, organization_id: @organization.id
    )
    @request.host = "#{@organization.identification}.lvh.me"

    sign_in user
  end

  test "should get index" do
    get :index, format: :js
    assert_response :success
  end
end
