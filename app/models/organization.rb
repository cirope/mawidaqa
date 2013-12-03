class Organization < ActiveRecord::Base
  has_paper_trail

  has_magick_columns name: :string, identification: :string

  # attr_accessible :name, :identification, :lock_version

  alias_attribute :label, :name
  alias_attribute :informal, :identification

  # Default order
  default_scope -> { order("#{table_name}.name ASC") }

  #callbacks
  before_save :create_folder, on: :create

  #Validations
  validates :name, :identification, presence: true
  validates :name, :identification, length: { maximum: 255 }, allow_nil: true,
    allow_blank: true
  validates :identification, format: { with: /\A[a-z\d]+(-[a-z\d]+)*\z/ },
    allow_nil: true, allow_blank: true
  validates :identification, uniqueness: { case_sensitive: false },
    allow_nil: true, allow_blank: true
  validates :identification, exclusion: { in: RESERVED_SUBDOMAINS },
    allow_nil: true, allow_blank: true

  #Relations
  has_many :documents, dependent: :destroy
  has_many :workers, dependent: :destroy, class_name: 'Job'
  has_many :users, through: :workers
  has_many :tags, dependent: :destroy

  def to_s
    self.name
  end

  def create_folder
    if self.xml_reference.blank?
      self.xml_reference = GdataExtension::Base.new.create_and_share_folder(
        Rails.env.production? ? self.identification : "#{Rails.env.upcase} - #{self.identification}"
      ).to_s
    end
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
    query.present? ? magick_search(query) : all
  end
end
