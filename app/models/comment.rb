class Comment < ActiveRecord::Base
  include Associations::DestroyPaperTrail

  has_paper_trail

  # Restrictions
  validates :content, presence: true

  # Relations
  belongs_to :commentable, polymorphic: true
end
