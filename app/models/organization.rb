class Organization < ActiveRecord::Base
  has_paper_trail

  has_magick_columns name: :string, identification: :string

  attr_accessible :name, :identification, :lock_version

  alias_attribute :label, :name
  alias_attribute :informal, :identification

  # Default order
  default_scope order("#{table_name}.name ASC")

  #Validations
  validates :name, :identification, presence: true
  validates :name, :identification, length: { maximum: 255 }, allow_nil: true,
    allow_blank: true
  validates :identification, format: { with: /\A[a-z\d]+(-[a-z\d]+)*\z/i },
    allow_nil: true, allow_blank: true
  validates :identification, uniqueness: { case_sensitive: false },
    allow_nil: true, allow_blank: true
  validates :identification, exclusion: { in: RESERVED_SUBDOMAINS },
    allow_nil: true, allow_blank: true

  #Relations
  has_many :workers, dependent: :destroy, class_name: 'Job'
  has_many :users, through: :workers

  def to_s
    self.name
  end

  def inspect
    [
      ("[#{self.identification}]" if self.identification.present?), self.name
    ].compact.join(' ')
  end

  def as_json(options = nil)
    default_options = {
      only: [:id],
      methods: [:label, :informal]
    }

    super(default_options.merge(options || {}))
  end

  def organization
    self
  end

  def self.filtered_list(query)
    query.present? ? magick_search(query) : scoped
  end
end
