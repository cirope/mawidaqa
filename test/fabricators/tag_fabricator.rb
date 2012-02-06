Fabricator(:tag) do
  name { (Faker::Lorem.words(2) + [sequence(:tag_name)]).join(' ') }
end
