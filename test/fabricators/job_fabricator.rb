Fabricator(:job) do
  job { Job::TYPES.sample }
  user_id { Fabricate(:user).id }
  organization_id { Fabricate(:organization).id }
end
