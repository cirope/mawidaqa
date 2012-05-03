class Ability
  include CanCan::Ability

  def initialize(user)
    user ? user_rules(user) : default_rules
  end
  
  def user_rules(user)
    user.roles.each do |role|
      send("#{role}_rules") if respond_to?("#{role}_rules")
    end
    
    default_rules
  end
  
  def admin_rules
    can :manage, :all
  end
  
  def regular_rules
    can :edit_profile, User
    can :update_profile, User
    
    common_document_rules
  end
  
  def approver_rules
    can :edit_profile, User
    can :update_profile, User
    
    common_document_rules
    
    can :approve, Document, status: 'revised'
    can :reject, Document, status: ['on_revision', 'revised']
  end
  
  def reviewer_rules
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
  
  def default_rules
    can :read, Document
  end
  
  def common_document_rules
    cannot :manage, Document # Permissions reset
    can :create, Document
    can :update, Document, status: 'on_revision'
    can :destroy, Document, status: 'on_revision'
    can :create_new_revision, Document, status: ['approved', 'on_revision']
  end
end
