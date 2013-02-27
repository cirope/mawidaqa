class Document < ActiveRecord::Base
  include AASM
  
  has_paper_trail version: :paper_trail_version
  
  has_magick_columns 'documents.name' => :string, code: :string
  
  acts_as_nested_set scope: :organization_id

  KINDS = ['document', 'spreadsheet']

  # Scopes
  default_scope order("#{table_name}.code ASC")
  scope :approved, where("#{table_name}.status = ?", 'approved')
  scope :on_revision_or_revised, where(
    [
      "#{table_name}.status = :on_revision",
      "#{table_name}.status = :revised"
    ].join(' OR '),
    on_revision: 'on_revision', revised: 'revised'
  )
  scope :visible, where(
    [
      [
        "#{table_name}.parent_id IS NULL",
        "#{table_name}.status = :approved"
      ].join(' OR '),
      "#{table_name}.status NOT IN (:hidden_status)"
    ].map { |c| "(#{c})" }.join(' AND '),
    approved: 'approved',
    hidden_status: ['obsolete']
  )
  
  # Attributes without persistence
  attr_accessor :tag_list_cache
  attr_accessor :skip_code_uniqueness
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :code, :version, :notes, :version_comments, :kind,
    :tag_list, :parent_id, :lock_version, :comments_attributes,
    :changes_attributes, :organization_id
  attr_readonly :kind
  
  # Callbacks
  before_validation :check_code_changes
  before_save :create_doc, on: :create
  before_save :tag_list_asign
  
  aasm column: :status do
    state :on_revision, initial: true
    state :approved
    state :revised
    state :obsolete

    event :revise, before: :retrieve_revision_url do
      transitions to: :revised, from: :on_revision
    end
    
    event :approve, after: :mark_related_as_obsolete do
      transitions to: :approved, from: :revised
    end
    
    event :reject, before: :remove_revision_url do
      transitions to: :on_revision, from: [:revised]
    end
    
    event :mark_as_obsolete do
      transitions to: :obsolete, from: :approved
    end
    
    event :reset_status do
      transitions to: :on_revision, from: :approved
    end
  end
  
  # Restrictions
  validates :name, :code, :status, :version, :kind, :organization_id, presence: true
  validates :name, :code, :version, length: { maximum: 255 }, allow_nil: true,
    allow_blank: true
  validates :code, uniqueness: { scope: :organization_id, case_sensitive: false },
    allow_nil: true, allow_blank: true, unless: :skip_code_uniqueness
  validates :kind, inclusion: { in: KINDS }, allow_nil: true, allow_blank: true
  validates_each :status do |record, attr, value|
    if record.on_revision?
      any_other_on_revision = record.root.self_and_descendants.any? do |d|
        d.on_revision? && d != record
      end
      
      record.errors.add attr, :taken if any_other_on_revision
    end
  end
  
  # Relations
  belongs_to :organization
  has_many :changes, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_and_belongs_to_many :tags

  accepts_nested_attributes_for :comments, reject_if: ->(attributes) {
    ['content'].all? { |a| attributes[a].blank? }
  }
  accepts_nested_attributes_for :changes, reject_if: ->(attributes) {
    ['made_at', 'content'].all? { |a| attributes[a].blank? }
  }
  
  def initialize(attributes = {}, options = {})
    super

    if self.parent
      self.parent.attributes.slice(*self.class.accessible_attributes).each do |a, v|
        self.send("#{a}=", v) if self.send(a).blank?
      end
      
      self.xml_reference = self.parent.xml_reference
      self.tag_list = self.parent.tag_list
      
      self.skip_code_uniqueness = (self.parent.code == self.code)
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
  
  def remove_revision_url
    self.revision_url = nil
  end

  def retrieve_revision_url
    self.revision_url = GdataExtension::Base.new.last_revision_url(
      self.xml_reference, !self.spreadsheet?
    )
  end
  
  def mark_related_as_obsolete
    self.ancestors.approved.all?(&:mark_as_obsolete!)
  end
  
  def is_on_revision?
    self.children.where(organization_id: self.organization_id).on_revision_or_revised.count > 0
  end
  
  def current_revision
    self.children.where(organization_id: self.organization_id).on_revision_or_revised.first
  end
  
  def may_create_revision?
    self.approved? && !self.is_on_revision?
  end
  
  def tag_list
    self.tags.map(&:to_s).join(',')
  end

  def tag_list=(tags)
    self.tag_list_cache = tags.to_s.split(/\s*,\s*/).reject(&:blank?)
  end
  
  def tag_list_asign
    if self.tag_list_cache
      # Remove the removed =)
      self.tags.delete *self.tags.reject { |t| self.tag_list_cache.include?(t.name) }

      # Add or create and add the new ones
      self.tag_list_cache.each do |tag|
        unless self.tags.map(&:name).include?(tag)
          self.tags << Tag.where(
            name: tag, organization_id: self.organization_id
          ).first_or_create!
        end
      end
    end
  end

  KINDS.each do |kind|
    define_method("#{kind}?") { self.kind == kind  }
  end
  
  def self.on_revision_with_parent(parent_id)
    Document.on_revision_or_revised.where(
      "#{table_name}.parent_id = ?", parent_id
    ).first || Document.new(parent_id: parent_id)
  end
  
  def self.filtered_list(query)
    query.present? ? visible.magick_search(query) : visible
  end
end
