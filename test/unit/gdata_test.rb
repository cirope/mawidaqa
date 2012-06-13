require 'test_helper'

class GdataTest < ActiveSupport::TestCase
  setup do
    @gdata = GdataExtension::Base.new
  end
  
  test 'create document' do
    xml_response = @gdata.create_document('Test document')
    
    assert_equal(
      GdataExtension::ResponseExamples::XML_CREATE.lines.to_a[1..-1].join,
      xml_response.to_s
    )
  end
  
  test 'create and share document' do
    xml_response = @gdata.create_and_share_document('Test document')
    
    assert_equal(
      GdataExtension::ResponseExamples::XML_CREATE.lines.to_a[1..-1].join,
      xml_response.to_s
    )
  end
  
  test 'retrieve last revision url' do
    response = @gdata.last_revision_url(
      GdataExtension::ResponseExamples::XML_CREATE
    )
    
    assert_equal(
      'https://docs.google.com/feeds/download/documents/Export?docId=doc_id&revision=2',
      response
    )
  end
end
