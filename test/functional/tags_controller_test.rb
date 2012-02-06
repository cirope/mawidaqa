require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  setup do
    sign_in Fabricate(:user)
  end
  
  test 'should get index' do
    2.times { Fabricate(:tag) { name { "Test #{sequence(:tag_name)}" } } }
    
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
