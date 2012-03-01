class Document < ActiveRecord::Base
  include AASM
  
  mount_uploader :file, FileUploader
  
  has_paper_trail version: :paper_trail_version
  
  acts_as_nested_set
  
  # Scopes
  scope :ordered_list, leaves.reorder('code ASC')
  
  # Attributes without persistence
  attr_accessor :skip_code_uniqueness
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :code, :version, :notes, :version_comments, :file,
    :file_cache, :tag_list, :lock_version
  
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
    
    event :approve do
      transitions to: :approved, from: :revised
    end
    
    event :reject do
      transitions to: :rejected, from: [:on_revision, :revised]
    end
    
    event :mark_as_obsolete do
      transitions to: :obsolete, from: :approved
    end
    
    event :reset_status do
      transitions to: :on_revision, from: [:approved]
    end
  end
  
  # Restrictions
  validates :name, :code, :status, :version, :file, presence: true
  validates :name, :code, length: { maximum: 255 }, allow_nil: true,
    allow_blank: true
  validates :code, uniqueness: { case_sensitive: false },
    allow_nil: true, allow_blank: true, unless: :skip_code_uniqueness
  validates :version, numericality: { only_integer: true, greater_than: 0 },
    allow_nil: true, allow_blank: true
  
  # Relations
  has_and_belongs_to_many :tags
  
  def to_s
    "[#{self.code}] #{self.name}"
  end
  
  def check_code_changes
    self.skip_code_uniqueness = true unless self.code_changed?
  end
  
  def file=(file)
    if self.persisted? && self.file.try(:path) && File.exist?(self.file.path)
      old_file = self.file.path
      new_file = file.respond_to?(:path) ? file.path : file
      
      if File.exists?(new_file) && !FileUtils.compare_file(old_file, new_file)
        self.build_parent(
          self.attributes.slice(*self.class.accessible_attributes)
        )

        if self.approved?
          self.parent.status = self.status
          self.reset_status
        end
        
        self.parent.file = File.open(old_file)
        self.parent.skip_code_uniqueness = !self.code_changed?
      end
    end
    
    super(file)
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
end
