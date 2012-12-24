Fabricator(:organization) do
  name { Faker::Company.name }
  identification do |attrs|
    [
      attrs[:name].gsub(/[^a-z\d\-]/i, '').downcase,
      sequence(:organization_identification)
    ].join
  end
end
