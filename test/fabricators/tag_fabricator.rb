Fabricator(:basic_tag, class_name: :tag) do
  name { (Faker::Lorem.words(2) + [sequence(:tag_name)]).join(' ') }
end

Fabricator(:tag, from: :basic_tag, class_name: :tag) do
  organization_id { Fabricate(:organization).id }
end
