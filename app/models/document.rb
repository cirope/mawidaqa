class Document < ActiveRecord::Base
  mount_uploader :file, FileUploader
  
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
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :code, :status, :version, :notes, :version_comments,
    :file, :file_cache, :tag_list, :lock_version
  
  # Restrictions
  validates :name, :code, :status, :version, presence: true
  validates :name, :code, length: { maximum: 255 }, allow_nil: true,
    allow_blank: true
  validates :code, uniqueness: { case_sensitive: false }, allow_nil: true,
    allow_blank: true
  validates :status, inclusion: { in: STATUS.values }, allow_nil: true,
    allow_blank: true
  validates :version, numericality: { only_integer: true, greater_than: 0 },
    allow_nil: true, allow_blank: true
  
  # Relations
  has_and_belongs_to_many :tags
  
  def to_s
    "[#{self.code}] #{self.name}"
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
        self.tags << Tag.find_or_create_by_name(tag)
      end
    end
  end
end
