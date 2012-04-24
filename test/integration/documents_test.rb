require 'test_helper'

class DocumentsTest < ActionDispatch::IntegrationTest
  test 'creates a new document' do
    login
    
    within '.navbar .container' do
      click_link I18n.t('menu.documents')
      find('ul.dropdown-menu li a').click
    end
    
    sleep 0.5
    assert_equal documents_path, current_path
    
    assert_page_has_no_errors!
    
    within '.form-actions' do
      click_link I18n.t('label.new')
    end
    
    sleep 0.5
    assert_equal new_document_path, current_path
    
    assert_page_has_no_errors!
    
    document = Fabricate.build(:document)
    
    fill_in 'document_name', with: document.name
    fill_in 'document_code', with: document.code
    fill_in 'document_version', with: document.version
    attach_file 'document_file', document.file.path
    fill_in 'document_notes', with: document.notes
    fill_in 'document_version_comments', with: document.version_comments
    
    assert_difference 'Document.count' do
      find('.btn.btn-primary').click
    end
    
    document = Document.find_by_code(document.code)
    
    assert_equal document_path(document), current_path
    
    assert_page_has_no_errors!
  end
end
