stub_request(:post, 'https://www.google.com/accounts/ClientLogin').with(
  body: {
    'Email' => APP_CONFIG['smtp']['user_name'],
    'Passwd' => APP_CONFIG['smtp']['password'],
    'accountType' => 'HOSTED_OR_GOOGLE',
    'service' => 'writely',
    'source' => 'GoogleDataRubyUtil-AnonymousApp'
  },
  headers: {
    'Accept' => '*/*',
    'Content-Type' => 'application/x-www-form-urlencoded',
    'User-Agent' => 'Ruby'
  }
).to_return(
  body: <<-EOF
SID=DQAAAGgA7Zg8CTN
LSID=DQAAAGsAlk8BBbG
Auth=DQAAAGgAdk3fA5N
  EOF
)

stub_request(:post, GdataExtension::URL_CREATE).to_return(
  body: GdataExtension::ResponseExamples::XML_CREATE
)

stub_request(
  :post,
  /https:\/\/docs.google.com\/feeds\/default\/private\/full\/.+\/acl/
).to_return(
  body: GdataExtension::ResponseExamples::XML_NEW_ACL
)

stub_request(
  :get,
  GdataExtension::Parser.revisions_url(
    GdataExtension::ResponseExamples::XML_CREATE
  )
).to_return(
  body: GdataExtension::ResponseExamples::XML_ACL
)