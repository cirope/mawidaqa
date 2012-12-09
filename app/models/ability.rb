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
      author_rules(user, organization)   if @job.author?
    end
    
    common_document_rules

    default_rules(user, organization) if organization
  end
  
  def approver_rules(user, organization)
    can :create, Comment
    can :edit_profile, User
    can :update_profile, User
    
    common_document_rules
    
    can :approve, Document, status: 'revised'
    can :reject, Document, status: ['on_revision', 'revised']
  end
  
  def reviewer_rules(user, organization)
    can :create, Comment
    can :create, Document
    can :update, Document
    can :destroy, Document
    can :revise, Document
    can :edit_profile, User
    can :update_profile, User
    
    common_document_rules
    
    can :revise, Document, status: 'on_revision'
    can :reject, Document, status: ['on_revision', 'revised']
  end
  
  def default_rules(user, organization)
    can :read, Document
    can :read, Comment
  end
  
  def common_document_rules
    cannot :manage, Document # Permissions reset
    can :create, Document
    can :update, Document, status: 'on_revision'
    can :destroy, Document, status: 'on_revision'
    can :create_revision, Document
  end
end
