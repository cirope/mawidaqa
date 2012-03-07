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
    can :create, Document
    can :update, Document
    can :destroy, Document
    can :edit_profile, User
    can :update_profile, User
  end
  
  def approver_rules
    can :create, Document
    can :update, Document
    can :destroy, Document
    can :approve, Document
    can :reject, Document
    can :edit_profile, User
    can :update_profile, User
  end
  
  def reviewer_rules
    can :create, Document
    can :update, Document
    can :destroy, Document
    can :revise, Document
    can :edit_profile, User
    can :update_profile, User
  end
  
  def default_rules
    can :read, Document
  end
end
