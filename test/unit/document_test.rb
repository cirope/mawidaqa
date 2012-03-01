require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  def setup
    @document = Fabricate(:document)
  end
  
  test 'create' do
    assert_difference ['Document.count', 'Version.count'] do
      @document = Document.create(Fabricate.attributes_for(:document))
    end
  end
  
  test 'update' do
    assert_difference 'Version.count' do
      assert_no_difference 'Document.count' do
        assert @document.update_attributes(name: 'Updated')
      end
    end
    
    assert_equal 'Updated', @document.reload.name
  end
  
  test 'destroy' do
    assert_difference 'Version.count' do
      assert_difference('Document.count', -1) { @document.destroy }
    end
  end
  
  test 'validates blank attributes' do
    @document.name = ''
    @document.code = ''
    @document.status = nil
    @document.version = nil
    @document.remove_file!
    
    assert @document.invalid?
    assert_equal 5, @document.errors.size
    assert_equal [error_message_from_model(@document, :name, :blank)],
      @document.errors[:name]
    assert_equal [error_message_from_model(@document, :code, :blank)],
      @document.errors[:code]
    assert_equal [error_message_from_model(@document, :status, :blank)],
      @document.errors[:status]
    assert_equal [error_message_from_model(@document, :version, :blank)],
      @document.errors[:version]
    assert_equal [error_message_from_model(@document, :file, :blank)],
      @document.errors[:file]
  end
  
  test 'validates well formated attributes' do
    @document.version = '1x.2'
    
    assert @document.invalid?
    assert_equal 1, @document.errors.size
    assert_equal [error_message_from_model(@document, :version, :not_a_number)],
      @document.errors[:version]
  end
  
  test 'validates unique attributes' do
    new_document = Fabricate(:document)
    @document.code = new_document.code
    
    assert @document.invalid?
    assert_equal 1, @document.errors.size
    assert_equal [error_message_from_model(@document, :code, :taken)],
      @document.errors[:code]
  end
  
  test 'validates attributes are in range' do
    @document.version = '0'
    
    assert @document.invalid?
    assert_equal 1, @document.errors.count
    assert_equal [
      error_message_from_model(@document, :version, :greater_than, count: 0)
    ], @document.errors[:version]
  end
  
  test 'validates length of _long_ attributes' do
    @document.name = 'abcde' * 52
    @document.code = 'abcde' * 52
    
    assert @document.invalid?
    assert_equal 2, @document.errors.count
    assert_equal [
      error_message_from_model(@document, :name, :too_long, count: 255)
    ], @document.errors[:name]
    assert_equal [
      error_message_from_model(@document, :code, :too_long, count: 255)
    ], @document.errors[:code]
  end
  
  test 'states transitions from on_revision' do
    assert @document.on_revision?
    assert !@document.may_approve?
    assert @document.may_revise?
    assert @document.may_reject?
    assert !@document.may_mark_as_obsolete?
    
    assert @document.revise
    assert @document.revised?
    assert @document.may_approve?
    assert @document.may_reject?
    assert !@document.may_mark_as_obsolete?
    
    assert @document.approve
    assert @document.approved?
    assert !@document.may_revise?
    assert !@document.may_reject?
    assert @document.may_mark_as_obsolete?
    
    assert @document.mark_as_obsolete
    assert @document.obsolete?
    assert !@document.may_revise?
    assert !@document.may_reject?
    assert !@document.may_approve?
  end
  
  test 'create parent when file change' do
    assert @document.revise!
    assert @document.approve!
    
    assert_difference 'Document.count' do
      assert @document.update_attributes(
        file: Rack::Test::UploadedFile.new(
          File.join(Rails.root, 'test', 'fixtures', 'files', 'test_2.txt'),
          'text/plain',
          false
        )
      )
    end
    
    assert_not_nil @document.reload.parent
    assert @document.parent.approved?
    assert @document.on_revision?
  end
  
  test 'do not create parent when the same file is uploaded' do
    assert_no_difference 'Document.count' do
      assert @document.update_attributes(
        file: Fabricate.attributes_for(:document)['file']
      )
    end
    
    assert_nil @document.parent
  end
  
  test 'read tag list' do
    @document = Fabricate(:document) do
      tags!(count: 2) { |a, i| Fabricate(:tag, name: "Test #{i}") }
    end
    
    assert_equal 'Test 1,Test 2', @document.tag_list
  end
  
  test 'write tag list' do
    @document = Fabricate(:document) do
      tags!(count: 1) { |a, i| Fabricate(:tag, name: 'Test') }
    end
    
    assert_difference ['Tag.count', '@document.tags.count'], 2 do
      assert @document.update_attributes(
        tag_list: 'Test, Multi word tag,NewTag, '
      )
    end
    
    assert_equal 'Test,Multi word tag,NewTag', @document.reload.tag_list
    
    assert_difference '@document.tags.count', -2 do
      assert_no_difference 'Tag.count' do
        assert @document.update_attributes(tag_list: 'NewTag, ')
      end
    end
    
    assert_equal 'NewTag', @document.reload.tag_list
    
    assert_difference '@document.tags.count', -1 do
      assert_no_difference 'Tag.count' do
        assert @document.update_attributes(tag_list: '')
      end
    end
    
    assert_equal '', @document.reload.tag_list
  end
end
