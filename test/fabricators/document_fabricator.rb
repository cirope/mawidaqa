Fabricator(:document) do
  name { "Document #{sequence(:document_name)}" }
  code { "DT #{'%.3d' % sequence(:document_code)}" }
  version { "#{Time.now.year}.#{'%.2d' % Time.now.month}" }
  notes { Faker::Lorem.sentences(3).join("\n") }
  version_comments { Faker::Lorem.sentences(3).join("\n") }
end

Fabricator(:document_with_relations, from: :document, class_name: :document) do
  comments(count: 1)
  changes(count: 1)
end