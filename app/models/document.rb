class Document < ActiveRecord::Base
  include AASM
  
  mount_uploader :file, FileUploader
  
  has_paper_trail version: :paper_trail_version
  
  has_magick_columns name: :string, code: :string
  
  acts_as_nested_set
  
  # Scopes
  default_scope order("#{table_name}.code ASC")
  scope :approved, where("#{table_name}.status = ?", 'approved')
  scope :on_revision_or_revised, where(
    [
      "#{table_name}.status = :on_revision",
      "#{table_name}.status = :revised",
    ].join(' OR '),
    on_revision: 'on_revision', revised: 'revised'
  )
  scope :visible, where(
    [
      [
        "#{table_name}.parent_id IS NULL",
        "#{table_name}.status = :approved"
      ].join(' OR '),
      "#{table_name}.status NOT IN (:hidden_status)"
    ].map { |c| "(#{c})" }.join(' AND '),
    approved: 'approved',
    hidden_status: ['obsolete', 'rejected']
  )
  
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
  validates_each :status do |record, attr, value|
    if record.on_revision?
      any_other_on_revision = record.root.self_and_descendants.any? do |d|
        d.on_revision? && d != record
      end
      
      record.errors.add attr, :taken if any_other_on_revision
    end
  end
  
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
  
  def is_on_revision?
    self.children.on_revision_or_revised.count > 0
  end
  
  def current_revision
    self.children.on_revision_or_revised.first
  end
  
  def may_create_new_revision?
    self.approved? && !self.is_on_revision?
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
  
  def self.on_revision_with_parent(parent_id)
    Document.on_revision_or_revised.where(
      "#{table_name}.parent_id = ?", parent_id
    ).first || Document.new(parent_id: parent_id)
  end
  
  def self.filtered_list(query)
    query.present? ? visible.magick_search(query) : visible
  end
end
