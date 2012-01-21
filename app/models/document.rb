class Document < ActiveRecord::Base
   mount_uploader :file, FileUploader
  
  # Constantes
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
    :file, :file_cache, :lock_version
  
  # Restricciones
  validates :name, :code, :status, :version, presence: true
  validates :name, :code, length: { maximum: 255 }, allow_nil: true,
    allow_blank: true
  validates :code, uniqueness: { case_sensitive: false }, allow_nil: true,
    allow_blank: true
  validates :status, inclusion: { in: STATUS.values }, allow_nil: true,
    allow_blank: true
  validates :version, numericality: { only_integer: true, greater_than: 0 },
    allow_nil: true, allow_blank: true
  
  def to_s
    "[#{self.code}] #{self.name}"
  end
end
