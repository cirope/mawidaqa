class Comment < ActiveRecord::Base
  has_paper_trail

  # attr_accessible :content, :commentable_id, :lock_version

  # Restrictions
  validates :content, presence: true

  # Relations
  belongs_to :commentable, polymorphic: true
end
