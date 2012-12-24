require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  setup do
    @organization = Fabricate(:organization)
    user = Fabricate(:user, role: :regular)
    job = Fabricate(
      :job, job: 'author', user_id: user.id, organization_id: @organization.id
    )
    @request.host = "#{@organization.identification}.lvh.me"

    sign_in user
  end
  
  test 'should get index' do
    2.times { Fabricate(:tag, organization_id: @organization.id) { name { "Test #{sequence(:tag_name)}" } } }
    
    get :index, q: 'test', format: 'json'
    assert_response :success
    
    tags = ActiveSupport::JSON.decode(@response.body)
    
    assert_equal 2, tags.size
    assert tags.all? { |t| t['name'].match /test/i }
    
    get :index, q: 'no_tag', format: 'json'
    assert_response :success
    
    tags = ActiveSupport::JSON.decode(@response.body)
    
    assert_equal 0, tags.size
  end
end
