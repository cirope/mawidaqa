module Documents::Revisions
  extend ActiveSupport::Concern

  included do
    scope :on_revision_or_revised, where(
      [
        "#{table_name}.status = :on_revision",
        "#{table_name}.status = :revised"
      ].join(' OR '),
      on_revision: 'on_revision', revised: 'revised'
    )

    validates_each :status do |record, attr, value|
      if record.on_revision?
        any_other_on_revision = record.root.self_and_descendants.any? do |d|
          d.on_revision? && d != record
        end
        
        record.errors.add attr, :taken if any_other_on_revision
      end
    end
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
  
  module ClassMethods
    def on_revision_with_parent(parent_id)
      Document.on_revision_or_revised.where(
        "#{table_name}.parent_id = ?", parent_id
      ).first || Document.new(parent_id: parent_id)
    end
  end
end
