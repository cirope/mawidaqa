Fabricator(:comment) do
  content { Faker::Lorem.sentences(3).join("\n") }
  file {
    Rack::Test::UploadedFile.new(
      "#{Rails.root}/test/fixtures/files/test.txt", 'text/plain', false
    )
  }
  commentable { Fabricate(:document) }
end
