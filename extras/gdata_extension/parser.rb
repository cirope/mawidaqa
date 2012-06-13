module GdataExtension
  module Parser
    def self.preview_url(raw_xml)
      extract(
        raw_xml: raw_xml,
        element: 'link',
        rel_condition: /#embed\z/
      )
    end
    
    def self.edit_url(raw_xml)
      extract(
        raw_xml: raw_xml,
        element: 'link',
        rel_condition: /\Aalternate\z/
      )
    end
    
    def self.revisions_url(raw_xml)
      extract(
        raw_xml: raw_xml,
        element: 'gd:feedLink',
        rel_condition: /revisions\z/
      )
    end
    
    def self.acl_url(raw_xml)
      extract(
        raw_xml: raw_xml,
        element: 'gd:feedLink',
        rel_condition: /#accessControlList\z/
      )
    end
    
    def self.last_revision_url(revision_xml)
      xml = REXML::Document.new(revision_xml)
      url = nil
      
      xml.root.elements.each('entry') do |entry|
        entry.elements.each('content') do |link|
          url = link.attribute('src').value
        end
      end

      url
    end
    
    private
    
    def self.extract(options)
      xml = REXML::Document.new(options[:raw_xml])
      url = nil

      xml.root.elements.each(options[:element]) do |l|
        if l.attribute('rel').value =~ options[:rel_condition]
          url = l.attribute('href').value
        end
      end

      url
    end
  end
end