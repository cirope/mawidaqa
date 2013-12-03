class Document < ActiveRecord::Base
  include Documents::Revisions
  include Documents::StateMachine
  include Documents::Tags

  has_paper_trail version: :paper_trail_version

  has_magick_columns 'documents.name' => :string, code: :string

  acts_as_tree

  KINDS = ['document', 'spreadsheet']

  # Scopes
  default_scope -> { order("#{table_name}.code ASC") }
  scope :approved, -> { where("#{table_name}.status = ?", 'approved') }
  scope :visible, -> {
    where(
      [
        [
          "#{table_name}.parent_id IS NULL",
          "#{table_name}.status = :approved"
        ].join(' OR '),
        "#{table_name}.status <> :hidden_status"
      ].map { |c| "(#{c})" }.join(' AND '),
      approved: 'approved',
      hidden_status: 'obsolete'
    )
  }

  # Attributes without persistence
  attr_accessor :skip_code_uniqueness

  # Readonly attributes...
  attr_readonly :kind

  # Callbacks
  before_validation :check_code_changes
  before_save :create_doc, on: :create

  # Restrictions
  validates :name, :code, :status, :version, :kind, :organization_id, presence: true
  validates :name, :code, :version, length: { maximum: 255 }, allow_nil: true,
    allow_blank: true
  validates :code, uniqueness: { scope: :organization_id, case_sensitive: false },
    allow_nil: true, allow_blank: true, unless: :skip_code_uniqueness
  validates :kind, inclusion: { in: KINDS }, allow_nil: true, allow_blank: true

  # Relations
  belongs_to :organization
  has_many :changes, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  accepts_nested_attributes_for :comments, reject_if: ->(attributes) {
    ['content'].all? { |a| attributes[a].blank? }
  }
  accepts_nested_attributes_for :changes, reject_if: ->(attributes) {
    ['made_at', 'content'].all? { |a| attributes[a].blank? }
  }

  def initialize(attributes = {}, options = {})
    super

    if parent
      parent.dup.attributes.except('status').each do |a, v|
        send("#{a}=", v) if send(a).blank?
      end

      self.xml_reference = parent.xml_reference
      self.tag_list = parent.tag_list

      self.skip_code_uniqueness = (parent.code == self.code)
    end
  end

  def to_s
    "[#{self.code}] #{self.name}"
  end

  def create_doc
    if self.xml_reference.blank? # only create for the new ones...
      name = Rails.env.production? ? self.code : "#{Rails.env.upcase} - #{self.code}"
      self.xml_reference = GdataExtension::Base.new.send(
        "create_resource_#{self.kind}", name, self.organization.xml_reference
      ).to_s
    end
  end

  def check_code_changes
    self.skip_code_uniqueness = true unless self.code_changed?
  end

  KINDS.each do |kind|
    define_method("#{kind}?") { self.kind == kind  }
  end

  def self.filtered_list(query)
    query.present? ? visible.magick_search(query) : visible
  end
end
