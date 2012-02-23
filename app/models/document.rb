class Document < ActiveRecord::Base
  mount_uploader :file, FileUploader
  
  has_paper_trail version: :paper_trail_version
  
  acts_as_nested_set
  
  # Constants
  STATUS = {
    approved: 0,
    on_revision: 1,
    revised: 2,
    obsolete: 3,
    rejected: 4
  }.freeze
  
  # Scopes
  scope :ordered_list, order('code ASC')
  
  # Attributes without persistence
  attr_accessor :skip_code_uniqueness
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :code, :status, :version, :notes, :version_comments,
    :file, :file_cache, :tag_list, :lock_version
  
  # Restrictions
  validates :name, :code, :status, :version, :file, presence: true
  validates :name, :code, length: { maximum: 255 }, allow_nil: true,
    allow_blank: true
  validates :code, uniqueness: { case_sensitive: false},
    allow_nil: true, allow_blank: true, unless: :skip_code_uniqueness
  validates :status, inclusion: { in: STATUS.values }, allow_nil: true,
    allow_blank: true
  validates :version, numericality: { only_integer: true, greater_than: 0 },
    allow_nil: true, allow_blank: true
  
  # Relations
  has_and_belongs_to_many :tags
  
  def initialize(attributes = nil, options = {})
    super(attributes, options)

    self.on_revision!
  end
  
  def to_s
    "[#{self.code}] #{self.name}"
  end
  
  def file=(file)
    if self.persisted? && self.file.try(:path) && File.exist?(self.file.path)
      old_file = self.file.path
      new_file = file.respond_to?(:path) ? file.path : file
      
      if File.exists?(new_file) && !FileUtils.compare_file(old_file, new_file)
        self.build_parent(
          self.attributes.slice(*self.class.accessible_attributes)
        )

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
  
  STATUS.each do |status, value|
    define_method("#{status}?") { self.status == value }
    define_method("#{status}!") { self.status = value }
  end
end
