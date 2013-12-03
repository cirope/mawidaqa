require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  setup do
    @comment = Fabricate(:comment)
  end

  test 'create' do
    assert_difference 'Comment.count' do
      @comment = Comment.create(Fabricate.attributes_for(:comment))
    end
  end

  test 'update' do
    assert_difference 'PaperTrail::Version.count' do
      assert_no_difference 'Comment.count' do
        assert @comment.update(content: 'Updated')
      end
    end

    assert_equal 'Updated', @comment.reload.content
  end

  test 'destroy' do
    assert_difference 'PaperTrail::Version.count' do
      assert_difference('Comment.count', -1) { @comment.destroy }
    end
  end

  test 'validates blank attributes' do
    @comment.content = ''

    assert @comment.invalid?
    assert_equal 1, @comment.errors.size
    assert_equal [error_message_from_model(@comment, :content, :blank)],
      @comment.errors[:content]
  end
end
