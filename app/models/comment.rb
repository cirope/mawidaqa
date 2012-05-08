class Comment < ActiveRecord::Base
  mount_uploader :file, FileUploader
  
  has_paper_trail
  
  attr_accessible :content, :file, :file_cache, :commentable_id, :lock_version
  
  # Restrictions
  validates :content, presence: true
  
  # Relations
  belongs_to :commentable, polymorphic: true
end
