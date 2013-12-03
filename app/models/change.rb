class Change < ActiveRecord::Base
  has_paper_trail

  # attr_accessible :content, :made_at, :document_id, :lock_version

  # Scopes
  default_scope -> { order("#{table_name}.made_at DESC") }

  # Restrictions
  validates :content, :made_at, presence: true
  validates :made_at, timeliness: { type: :date }, allow_nil: true,
    allow_blank: true

  # Relations
  belongs_to :document
end
