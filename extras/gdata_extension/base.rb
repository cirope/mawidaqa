module GdataExtension
  class Base
    def connect
      unless @connected
        @client = ::GData::Client::DocList.new(version: '3.0')

        APP_CONFIG['smtp'].tap do |config|
          @token = @client.clientlogin config['user_name'], config['password']
        end

        @connected = true
      end
    end
    
    TYPES.each_key do |type|
      define_method("create_#{type}") do |name|
        create(type: type, name: name)
      end
      
      define_method("create_and_share_#{type}") do |name|
        send("create_#{type}", name).tap do |xml|
          share(Parser.acl_url(xml.to_s))
        end
      end
  
      define_method("create_resource_#{type}") do |name, xml|
        create_resource(type: type, name: name, uri: xml)
      end
    end
     
    def list_root_folders
      self.connect
      Parser.folder_names(@client.get(URL_FOLDER_LIST).to_xml.to_s)
    end
    
    def share(uri)
      self.connect
      @client.post(uri, RequestTemplates::XML_ACL_SHARE).to_xml
    end
    
    def last_revision_url(xml, use_last)
      uri = Parser.revisions_url(xml)
      
      self.connect

      if use_last
        Parser.last_revision_url(@client.get(uri).to_xml.to_s)
      else
        Parser.first_revision_url(@client.get(uri).to_xml.to_s)
      end
    end
    
    private
    
    def create(*args)
      options = args.extract_options!
      type = options[:type] || :document
      name = options[:name] || 'Document'
      
      self.connect
      @client.post(
        URL_CREATE,
        RequestTemplates::XML_CREATE % {name: name, type: type}
      ).to_xml
    end

    def create_resource(*args)
      options = args.extract_options!

      if options[:uri].present?
        type = options[:type] || :document
        name = options[:name] || 'Document'
        uri = Parser.resource_url(options[:uri])

        self.connect
        @client.post(
          uri,
          RequestTemplates::XML_CREATE % {name: name, type: type}
        ).to_xml
      end
    end
  end
end
