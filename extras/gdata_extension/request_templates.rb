module GdataExtension
  module RequestTemplates
    XML_CREATE = <<-XML
<?xml version='1.0' encoding='UTF-8'?>
<entry xmlns="http://www.w3.org/2005/Atom" xmlns:docs="http://schemas.google.com/docs/2007">
  <category scheme="http://schemas.google.com/g/2005#kind"
      term="http://schemas.google.com/docs/2007#%{type}"/>
  <title>%{name}</title>
</entry>
    XML

    XML_ACL_SHARE = <<-XML
<?xml version='1.0' encoding='UTF-8'?>
<entry xmlns="http://www.w3.org/2005/Atom" xmlns:gAcl='http://schemas.google.com/acl/2007'>
  <category scheme='http://schemas.google.com/g/2005#kind'
      term='http://schemas.google.com/acl/2007#accessRule'/>
  <gAcl:withKey key='[ACL KEY]'><gAcl:role value='writer' /></gAcl:withKey>
  <gAcl:scope type='default' />
</entry>
    XML
  end
end