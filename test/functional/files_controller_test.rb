require 'test_helper'

class FilesControllerTest < ActionController::TestCase
  setup do
    sign_in Fabricate(:user)
  end
  
  test 'should download file' do
    document = Fabricate(
      :document, file: fixture_file_upload('files/test.txt', 'text/plain')
    )
    
    get :download, path: document.file.current_path.sub("#{PRIVATE_PATH}/", '')
    assert_response :success
    assert_equal(
      File.open(document.file.current_path, encoding: 'ASCII-8BIT').read,
      @response.body
    )
  end
  
  test 'should not download file' do
    get :download, path: 'wrong/path.txt'
    assert_redirected_to documents_url
    assert_equal I18n.t('view.documents.non_existent'), flash.notice
  end
end
