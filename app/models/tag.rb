class Tag < ActiveRecord::Base
  include Comparable
  
  has_paper_trail
  
  # Scopes
  default_scope order('name ASC')
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :organization_id
  
  # Validations
  validates :name, :organization_id, presence: true
  validates :name, uniqueness: { scope: :organization_id, case_sensitive: false },
    length: { maximum: 255 }
  
  # Relations
  belongs_to :organization
  has_and_belongs_to_many :documents
  
  def to_s
    self.name
  end
  
  def <=>(other)
    self.name <=> other.name
  end
  
  def as_json(options = nil)
    super({ only: [:name] }.merge(options || {}))
  end  
end
