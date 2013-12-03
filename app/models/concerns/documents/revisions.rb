module Documents::Revisions
  extend ActiveSupport::Concern

  included do
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
      xml_reference, !spreadsheet?
    )
  end

  def mark_related_as_obsolete
    ancestors.select(&:approved?).all?(&:mark_as_obsolete!)
  end

  def is_on_revision?
    children.where(organization_id: organization_id).on_revision_or_revised.exists?
  end

  def current_revision
    children.where(organization_id: organization_id).on_revision_or_revised.first
  end

  def may_create_revision?
    approved? && !is_on_revision?
  end

    module ClassMethods
      def on_revision_or_revised
        where "#{table_name}.status" => ['on_revision', 'revised']
      end

      def on_revision_with_parent(parent_id)
        on_revision_or_revised.where(
          "#{table_name}.parent_id = ?", parent_id
        ).first || new(parent_id: parent_id)
    end
  end
end
