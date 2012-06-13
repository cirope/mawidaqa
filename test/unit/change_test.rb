require 'test_helper'

class ChangeTest < ActiveSupport::TestCase
  setup do
    @change = Fabricate(:change)
  end
  
  test 'create' do
    assert_difference 'Change.count' do
      @change = Change.create(Fabricate.attributes_for(:change))
    end
  end
  
  test 'update' do
    assert_difference 'Version.count' do
      assert_no_difference 'Change.count' do
        assert @change.update_attributes(content: 'Updated')
      end
    end
    
    assert_equal 'Updated', @change.reload.content
  end
  
  test 'destroy' do
    assert_difference 'Version.count' do
      assert_difference('Change.count', -1) { @change.destroy }
    end
  end
  
  test 'validates blank attributes' do
    @change.content = ''
    @change.made_at = nil
    
    assert @change.invalid?
    assert_equal 2, @change.errors.size
    assert_equal [error_message_from_model(@change, :content, :blank)],
      @change.errors[:content]
    assert_equal [error_message_from_model(@change, :made_at, :blank)],
      @change.errors[:made_at]
  end
  
  test 'validates date attributes' do
    @change.made_at = '13/13/13'
    
    assert @change.invalid?
    assert_equal 2, @change.errors.size
    assert_equal [
      error_message_from_model(@change, :made_at, :invalid_date),
      error_message_from_model(@change, :made_at, :blank)
    ].sort, @change.errors[:made_at].sort
  end
end
