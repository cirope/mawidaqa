Fabricator(:change) do
  content { Faker::Lorem.sentences(3).join("\n") }
  made_at { Date.today.to_s(:db) }
  document
end
