require 'test_helper'

class TagTest < ActiveSupport::TestCase
  def setup
    @tag = Fabricate(:tag)
  end
  
  test 'create' do
    assert_difference 'Tag.count' do
      @tag = Tag.create(Fabricate.attributes_for(:tag))
    end
  end
  
  test 'update' do
    assert_no_difference 'Tag.count' do
      assert @tag.update_attributes(name: 'Updated')
    end
    
    assert_equal 'Updated', @tag.reload.name
  end
  
  test 'destroy' do
    assert_difference('Tag.count', -1) { @tag.destroy }
  end
  
  test 'validates blank attributes' do
    @tag.name = ''
    
    assert @tag.invalid?
    assert_equal 1, @tag.errors.size
    assert_equal [error_message_from_model(@tag, :name, :blank)],
      @tag.errors[:name]
  end
  
  test 'validates unique attributes' do
    new_tag = Fabricate(:tag)
    @tag.name = new_tag.name.upcase
    
    assert @tag.invalid?
    assert_equal 1, @tag.errors.size
    assert_equal [error_message_from_model(@tag, :name, :taken)],
      @tag.errors[:name]
  end
  
  test 'validates length of _long_ attributes' do
    @tag.name = 'abcde' * 52
    
    assert @tag.invalid?
    assert_equal 1, @tag.errors.count
    assert_equal [
      error_message_from_model(@tag, :name, :too_long, count: 255)
    ], @tag.errors[:name]
  end
end
