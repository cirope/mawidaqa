Fabricator(:document) do
  name { "Document #{sequence(:document_name)}" }
  code { "DT #{sequence(:document_code)}" }
  status { Document::STATUS.values.sample }
  version { rand(5).next }
  notes { Faker::Lorem.sentences(3).join("\n") }
  version_comments { Faker::Lorem.sentences(3).join("\n") }
  file 'test.txt'
end
