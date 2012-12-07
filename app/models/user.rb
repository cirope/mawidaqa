class User < ActiveRecord::Base
  include RoleModel
  
  roles :admin, :regular
  
  has_paper_trail
  
  has_magick_columns name: :string, lastname: :string, email: :email
  
  devise :database_authenticatable, :recoverable, :rememberable, :trackable,
    :validatable, :lockable, :timeoutable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :lastname, :email, :password, :password_confirmation,
    :role, :remember_me, :jobs_attributes, :lock_version
  
  # Defaul order
  default_scope order('lastname ASC')
  
  # Validations
  validates :name, presence: true
  validates :name, :lastname, :email, length: { maximum: 255 }, allow_nil: true,
    allow_blank: true
 
  #Relations
  has_many :jobs, dependent: :destroy
  has_many :organizations, through: :jobs

  accepts_nested_attributes_for :jobs, allow_destroy: true,
    reject_if: ->(attributes) {
      attributes['job'].blank? && attributes['organization_id'].blank?
    }

  def initialize(attributes = nil, options = {})
    super
    
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
 
  def has_job_in?(organization)
    self.organizations.exists?(organization.id)
  end

  def self.filtered_list(query)
    query.present? ? magick_search(query) : scoped
  end

  def self.find_by_email_and_subdomain(email, subdomain)
    joins(:organizations).where(
      [
        "#{table_name}.email ILIKE :email",
        "#{Organization.table_name}.identification = :subdomain"
      ].join(' AND '),
        email: email, subdomain: subdomain
    ).readonly(false).first
  end

  def self.find_for_authentication(conditions = {})
    subdomains = conditions.delete(:subdomains)

    if subdomains.blank? || RESERVED_SUBDOMAINS.include?(subdomains.first)
      user = find_by_email(conditions[:email])

      user && (user.is?(:admin) || user.organizations.present?) ? user : nil
    else
      find_by_email_and_subdomain(conditions[:email], subdomains.first)
    end
  end
end
