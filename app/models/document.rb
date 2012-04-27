class Document < ActiveRecord::Base
  include AASM
  
  mount_uploader :file, FileUploader
  
  has_paper_trail version: :paper_trail_version
  
  has_magick_columns name: :string, code: :string
  
  acts_as_nested_set
  
  # Scopes
  default_scope order("#{table_name}.code ASC")
  scope :approved, where("#{table_name}.status = ?", 'approved')
  
  # Attributes without persistence
  attr_accessor :skip_code_uniqueness
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :code, :version, :notes, :version_comments, :file,
    :file_cache, :tag_list, :parent_id, :lock_version
  
  # Callbacks
  before_validation :check_code_changes
  
  aasm column: :status do
    state :on_revision, initial: true
    state :approved
    state :revised
    state :obsolete
    state :rejected
    
    event :revise do
      transitions to: :revised, from: :on_revision
    end
    
    event :approve, after: :mark_related_as_obsolete do
      transitions to: :approved, from: :revised
    end
    
    event :reject do
      transitions to: :rejected, from: [:on_revision, :revised]
    end
    
    event :mark_as_obsolete do
      transitions to: :obsolete, from: :approved
    end
    
    event :reset_status do
      transitions to: :on_revision, from: :approved
    end
  end
  
  # Restrictions
  validates :name, :code, :status, :version, :file, presence: true
  validates :name, :code, :version, length: { maximum: 255 }, allow_nil: true,
    allow_blank: true
  validates :code, uniqueness: { case_sensitive: false },
    allow_nil: true, allow_blank: true, unless: :skip_code_uniqueness
  
  # Relations
  has_and_belongs_to_many :tags
  
  def initialize(attributes = {}, options = {})
    super
    
    if self.parent
      self.parent.attributes.slice(*self.class.accessible_attributes).each do |a, v|
        self.send("#{a}=", v) if self.send(a).blank?
      end
      
      self.tag_list = self.parent.tag_list
      
      self.skip_code_uniqueness = (self.parent.code == self.code)
    end
  end
  
  def to_s
    "[#{self.code}] #{self.name}"
  end
  
  def check_code_changes
    self.skip_code_uniqueness = true unless self.code_changed?
  end
  
  def mark_related_as_obsolete
    self.ancestors.approved.all?(&:mark_as_obsolete!)
  end
  
  def tag_list
    self.tags.map(&:to_s).join(',')
  end
  
  def tag_list=(tags)
    tags = tags.to_s.split(/\s*,\s*/).reject(&:blank?)
    
    # Remove the removed =)
    self.tags.delete *self.tags.reject { |t| tags.include?(t.name) }
    
    # Add or create and add the new ones
    tags.each do |tag|
      unless self.tags.map(&:name).include?(tag)
        self.tags << Tag.all_by_name(tag).first_or_create!(name: tag)
      end
    end
  end
  
  def self.filtered_list(query)
    query.present? ? magick_search(query) : scoped
  end
end
