require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  def setup
    @document = Fabricate(:document)
  end
  
  test 'create' do
    assert_difference 'Document.count' do
      @document = Document.create(Fabricate.attributes_for(:document))
    end
  end
  
  test 'update' do
    assert_no_difference 'Document.count' do
      assert @document.update_attributes(name: 'Updated')
    end
    
    assert_equal 'Updated', @document.reload.name
  end
  
  test 'destroy' do
    assert_difference('Document.count', -1) { @document.destroy }
  end
  
  test 'validates blank attributes' do
    @document.name = ''
    @document.code = ''
    @document.status = nil
    @document.version = nil
    
    assert @document.invalid?
    assert_equal 4, @document.errors.size
    assert_equal [error_message_from_model(@document, :name, :blank)],
      @document.errors[:name]
    assert_equal [error_message_from_model(@document, :code, :blank)],
      @document.errors[:code]
    assert_equal [error_message_from_model(@document, :status, :blank)],
      @document.errors[:status]
    assert_equal [error_message_from_model(@document, :version, :blank)],
      @document.errors[:version]
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
    @document.status = Document::STATUS.values.sort.last.next
    
    assert @document.invalid?
    assert_equal 2, @document.errors.count
    assert_equal [
      error_message_from_model(@document, :version, :greater_than, count: 0)
    ], @document.errors[:version]
    assert_equal [error_message_from_model(@document, :status, :inclusion)],
      @document.errors[:status]
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
end
