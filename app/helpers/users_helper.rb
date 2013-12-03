module UsersHelper
  def show_user_roles_options(form)
    options = User.valid_roles.map { |r| [t("view.users.roles.#{r}"), r] }

    form.input :role, collection: options, as: :radio_buttons, label: false,
      input_html: { class: nil }
  end

  def show_user_job_options(form)
    jobs = Job::TYPES.map { |t| [show_human_job_type(t), t] }.sort

    form.input :job, label: false, collection: jobs, prompt: true,
      input_html: { class: 'span10' }
  end

  def show_human_job_type(job)
    t "view.jobs.types.#{job}"
  end

  def user_jobs(user)
    jobs = current_organization ?
    user.jobs.in_organization(current_organization).to_a : user.jobs.to_a

    jobs << (user.jobs.detect(&:new_record?) || user.jobs.build) if jobs.empty?

    jobs
  end
end
