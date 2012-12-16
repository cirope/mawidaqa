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
      approver_rules(organization) if @job.approver?
      reviewer_rules(organization) if @job.reviewer?
      author_rules                 if @job.author?
    end
    
    if organization
      common_document_rules(organization)
      default_rules(user, organization)
    end
  end
  
  def approver_rules(organization)
    can :create, Comment
    
    can :approve, Document, status: 'revised', organization_id: organization.id
    can :reject, Document, status: ['on_revision', 'revised'], organization_id: organization.id
  end
  
  def reviewer_rules(organization)
    can :create, Comment
    
    can :revise, Document, status: 'on_revision', organization_id: organization.id
    can :reject, Document, status: ['on_revision', 'revised'], organization_id: organization.id
  end

  def author_rules
    # Defaults rules
  end
  
  def default_rules(user, organization)
    can :edit_profile, User
    can :update_profile, User

    can :read, Organization, workers: { user_id: user.id }
    can :read, Comment
  end
  
  def common_document_rules(organization)
    #cannot :manage, Document # Permissions reset
    can :read, Document, organization_id: organization.id
    can :create, Document, organization_id: organization.id
    can :update, Document, status: 'on_revision', organization_id: organization.id
    can :destroy, Document, status: 'on_revision', organization_id: organization.id
    can :create_revision, Document, organization_id: organization.id
  end
end
