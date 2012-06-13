module GdataExtension
  module ResponseExamples
    EXAMPLES_DIR = ::File.expand_path('responses',  File.dirname(__FILE__))
    
    XML_CREATE = File.read(File.join(EXAMPLES_DIR, 'create.xml'))
    XML_ACL = File.read(File.join(EXAMPLES_DIR, 'acl.xml'))
    XML_NEW_ACL = File.read(File.join(EXAMPLES_DIR, 'new_acl.xml'))
  end
end