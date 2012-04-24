class User < ActiveRecord::Base
  include RoleModel
  
  roles :admin, :regular, :approver, :reviewer
  
  has_paper_trail
  
  has_magick_columns name: :string, lastname: :string, email: :email
  
  devise :database_authenticatable, :recoverable, :rememberable, :trackable,
    :validatable, :lockable, :timeoutable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :lastname, :email, :password, :password_confirmation,
    :role, :remember_me, :lock_version
  
  # Defaul order
  default_scope order('lastname ASC')
  
  # Validations
  validates :name, presence: true
  validates :name, :lastname, :email, length: { maximum: 255 }, allow_nil: true,
    allow_blank: true
  
  def initialize(attributes = nil, options = {})
    super(attributes, options)
    
    self.role ||= :regular
  end
  
  def to_s
    [self.name, self.lastname].compact.join(' ')
  end
  
  def role
    self.roles.first.try(:to_sym)
  end
  
  def role=(role)
    self.roles = [role]
  end
  
  def self.filtered_list(query)
    query.present? ? magick_search(query) : scoped
  end
end
