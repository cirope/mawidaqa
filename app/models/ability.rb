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
    can :create, :all
    can :update, :all
    can :destroy, :all
    can :edit_profile, User
    can :update_profile, User
  end
  
  def approver_rules
    can :create, :all
    can :update, :all
    can :destroy, :all
    can :edit_profile, User
    can :update_profile, User
    can :approve, Document
    can :reject, Document
  end
  
  def reviewer_rules
    can :create, :all
    can :update, :all
    can :destroy, :all
    can :edit_profile, User
    can :update_profile, User
    can :revise, Document
  end
  
  def default_rules
    can :read, :all
  end
end
