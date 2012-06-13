Fabricator(:comment) do
  content { Faker::Lorem.sentences(3).join("\n") }
  commentable { Fabricate(:document) }
end
