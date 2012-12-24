require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  setup do
    @document = Fabricate(:document)
    @organization = @document.organization
  end
  
  test 'create' do
    assert_difference ['Document.count', 'Version.count'] do
      @document = Document.create(
        Fabricate.attributes_for(:basic_document, organization_id: @organization.id)
      )
    end
    
    # create_doc callback
    assert @document.xml_reference.present?
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
    @document.version = ' '
    @document.organization_id = nil
    
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
    assert_equal [error_message_from_model(@document, :organization_id, :blank)],
      @document.errors[:organization_id]
  end
  
  test 'validates unique attributes' do
    new_document = Fabricate(:document, organization_id: @document.organization_id)
    @document.code = new_document.code
    
    assert @document.invalid?
    assert_equal 1, @document.errors.size
    assert_equal [error_message_from_model(@document, :code, :taken)],
      @document.errors[:code]
  end
  
  test 'validates length of _long_ attributes' do
    @document.name = 'abcde' * 52
    @document.code = 'abcde' * 52
    @document.version = 'abcde' * 52
    
    assert @document.invalid?
    assert_equal 3, @document.errors.count
    assert_equal [
      error_message_from_model(@document, :name, :too_long, count: 255)
    ], @document.errors[:name]
    assert_equal [
      error_message_from_model(@document, :code, :too_long, count: 255)
    ], @document.errors[:code]
    assert_equal [
      error_message_from_model(@document, :version, :too_long, count: 255)
    ], @document.errors[:version]
  end
  
  test 'validates only one status can be on_revision' do
    assert_difference 'Document.count', 2 do
      @document = Fabricate(:document, status: 'approved', organization_id: @organization.id)
      @document.children.create(
        Fabricate.attributes_for(:document, organization_id: @organization.id)
      )
    end
    
    document = @document.children.build(
      Fabricate.attributes_for(:document, organization_id: @organization.id)
    )
    
    assert document.invalid?
    assert_equal 1, document.errors.size
    assert_equal [error_message_from_model(document, :status, :taken)],
      document.errors[:status]
  end
  
  test 'should copy parent attributes in new' do
    new_document = Document.new(parent_id: @document.id)
    
    assert_equal new_document.name, @document.name
    assert_equal new_document.code, @document.code
    assert_equal new_document.version, @document.version
    assert_equal new_document.notes, @document.notes
    assert_equal new_document.version_comments, @document.version_comments
  end
  
  test 'states transitions from on_revision' do
    assert @document.on_revision?
    assert !@document.may_approve?
    assert @document.may_revise?
    assert !@document.may_reject?
    assert !@document.may_mark_as_obsolete?
    
    assert @document.revision_url.blank?
    assert @document.revise
    assert @document.revised?
    # retrieve_revision_url callback
    assert @document.revision_url.present?
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
  
  test 'mark related as obsolete' do
    parent_doc = Fabricate(:document, status: 'approved', organization_id: @organization.id)

    @document = Fabricate(:document, organization_id: @organization.id) {
      parent_id { parent_doc.id }
    }
    
    assert @document.parent.approved?
    assert @document.revise!
    assert @document.approve!
    assert @document.parent.reload.obsolete?
  end
  
  test 'is on revision' do
    @document = Fabricate(:document, status: 'approved', organization_id: @organization.id)
    
    assert !@document.is_on_revision?
    
    @document.children.create(Fabricate.attributes_for(:document, organization_id: @organization.id))
    
    assert @document.is_on_revision?
  end
  
  test 'current revision' do
    @document = Fabricate(:document, status: 'revised')

    assert @document.revised?
    assert @document.reject!
    assert @document.on_revision?
  end
  
  test 'may new revision' do
    assert @document.on_revision?
    assert !@document.may_create_revision?
    
    @document = Fabricate(:document, status: 'approved', organization_id: @organization.id)
    
    assert @document.may_create_revision?
    
    @document.children.create(Fabricate.attributes_for(:document, organization_id: @organization.id))
    
    assert !@document.may_create_revision?
  end
  
  test 'read tag list' do
    organization = Fabricate(:organization)

    @document = Fabricate(:document, organization_id: organization.id) do
      tags(count: 2) do |attrs, i| 
        Fabricate(:tag, name: "Test #{i}", organization_id: organization.id) 
      end
    end
    
    assert_equal 'Test 1,Test 2', @document.tag_list
  end
  
  test 'write tag list' do
    organization = Fabricate(:organization)

    @document = Fabricate(:document, organization_id: organization.id) do
      tags(count: 1) do |attrs, i| 
        Fabricate(:tag, name: 'Test', organization_id: organization.id)
      end
    end
    
    assert_difference ['Tag.count', '@document.tags.count'], 2 do
      assert @document.update_attributes(
        tag_list: 'Test, Multi word tag,NewTag, '
      )
    end
    
    assert_equal 'Multi word tag,NewTag,Test', @document.reload.tag_list
    
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
  
  test 'on revision with parent' do
    assert @document.revise!
    assert @document.approve!
    assert @document.save
    
    new_revision = Document.on_revision_with_parent(@document.id)
    
    assert new_revision.new_record?
    assert new_revision.save
    
    revision = Document.on_revision_with_parent(@document.id)
    
    assert revision.persisted?
  end
  
  test 'magick search' do
    5.times { |i| Fabricate(:document, code: "magick_code_#{i}") }
    3.times { |i| Fabricate(:document, name: "magick_name_#{i}") }
    Fabricate(:document, code: 'magick_code_x', name: 'magick_name_x')
    
    documents = Document.magick_search('magick')
    
    assert_equal 9, documents.count
    assert documents.all? { |d| d.to_s =~ /magick/ }
    
    documents = Document.magick_search('magick_code')
    
    assert_equal 6, documents.count
    assert documents.all? { |d| d.to_s =~ /magick_code/ }
    
    documents = Document.magick_search('magick_code magick_name')
    
    assert_equal 1, documents.count
    assert documents.all? { |d| d.to_s =~ /magick_code.*magick_name/ }
    
    documents = Document.magick_search(
      "magick_code #{I18n.t('magick_columns.or').first} magick_name"
    )
    
    assert_equal 9, documents.count
    assert documents.all? { |d| d.to_s =~ /magick_code|magick_name/ }
    
    documents = Document.magick_search('nothing')
    
    assert documents.empty?
  end
end
