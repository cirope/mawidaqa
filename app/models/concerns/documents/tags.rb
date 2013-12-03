module Documents::Tags
  extend ActiveSupport::Concern

  included do
    attr_accessor :tag_list_cache

    before_save :tag_list_asign

    has_and_belongs_to_many :tags
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
end
