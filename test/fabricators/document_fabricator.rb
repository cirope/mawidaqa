Fabricator(:document) do
  name { "Document #{sequence(:document_name)}" }
  code { "DT #{'%.3d' % sequence(:document_code)}" }
  version { rand(5).next }
  notes { Faker::Lorem.sentences(3).join("\n") }
  version_comments { Faker::Lorem.sentences(3).join("\n") }
  file {
    Rack::Test::UploadedFile.new(
      "#{Rails.root}/test/fixtures/files/test.txt", 'text/plain', false
    )
  }
end