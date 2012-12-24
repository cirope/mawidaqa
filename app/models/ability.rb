class Ability
  include CanCan::Ability

  def initialize(user, organization)
    @job = user.jobs.in_organization(organization).first if user && organization

    user ? user_rules(user, organization) : default_rules(user, organization)
  end
  
  def user_rules(user, organization)
    user.roles.each do |role|
      send("#{role}_rules", user, organization) if respond_to?("#{role}_rules")
    end
  end
  
  def admin_rules(user, organization)
    can :manage, :all
  end
  
  def regular_rules(user, organization)
    if @job
      approver_rules(user, organization) if @job.approver?
      reviewer_rules(user, organization) if @job.reviewer?
      author_rules                       if @job.author?
    end
    
    if organization
      common_document_rules(user, organization)
      default_rules(user, organization)
    end
  end
  
  def approver_rules(user, organization)
    jobs_restrictions = { 
      organization_id: organization.id, 
      organization: { workers: { user_id: user.id, job: 'approver' } }
    }

    can :create, Comment    
    can :approve, Document, { status: 'revised' }.merge(jobs_restrictions)
    can :reject, Document, { status: ['on_revision', 'revised'] }.merge(jobs_restrictions)
  end
  
  def reviewer_rules(user, organization)
    jobs_restrictions = { 
      organization_id: organization.id, 
      organization: { workers: { user_id: user.id, job: 'reviewer' } } 
    }

    can :create, Comment    
    can :revise, Document, { status: 'on_revision' }.merge(jobs_restrictions)
    can :reject, Document, { status: ['on_revision', 'revised'] }.merge(jobs_restrictions)
  end

  def author_rules
    # Defaults rules
  end
  
  def default_rules(user, organization)
    can :edit_profile, User
    can :update_profile, User

    can :read, Tag, organization_id: organization.id, organization: { workers: { user_id: user.id } }
    can :create, Tag, organization_id: organization.id
    can :read, Organization, workers: { user_id: user.id }
    can :read, Comment
  end
  
  def common_document_rules(user, organization)
    jobs_restrictions = { organization_id: organization.id, organization: { workers: { user_id: user.id } } }

    can :read, Document, jobs_restrictions
    can :create, Document, jobs_restrictions
    can :update, Document, { status: 'on_revision' }.merge(jobs_restrictions)
    can :destroy, Document, { status: 'on_revision'}.merge(jobs_restrictions)
    can :create_revision, Document, jobs_restrictions
  end
end
