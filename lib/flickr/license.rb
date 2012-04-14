module Flickr
  class License
    attr_reader :id, :name, :url

    private

    def initialize(argument)
      if argument.is_a?(Hash)
        @id = argument['id'].to_i
        @name = argument['name']
        @url = argument['url']
      elsif argument.respond_to?(:to_i)
        hash = self.class.response_array.find do
          |hash| hash['id'].to_i == argument.to_i
        end
        initialize(hash)
      end
    end

    def self.response_array
      [
        {"id"=>"0", "name"=>"All Rights Reserved", "url"=>""},
        {"id"=>"1", "name"=>"Attribution-NonCommercial-ShareAlike License", "url"=>"http://creativecommons.org/licenses/by-nc-sa/2.0/"},
        {"id"=>"2", "name"=>"Attribution-NonCommercial License", "url"=>"http://creativecommons.org/licenses/by-nc/2.0/"},
        {"id"=>"3", "name"=>"Attribution-NonCommercial-NoDerivs License", "url"=>"http://creativecommons.org/licenses/by-nc-nd/2.0/"},
        {"id"=>"4", "name"=>"Attribution License", "url"=>"http://creativecommons.org/licenses/by/2.0/"},
        {"id"=>"5", "name"=>"Attribution-ShareAlike License", "url"=>"http://creativecommons.org/licenses/by-sa/2.0/"},
        {"id"=>"6", "name"=>"Attribution-NoDerivs License", "url"=>"http://creativecommons.org/licenses/by-nd/2.0/"},
        {"id"=>"7", "name"=>"No known copyright restrictions", "url"=>"http://www.flickr.com/commons/usage/"},
        {"id"=>"8", "name"=>"United States Government Work", "url"=>"http://www.usa.gov/copyright.shtml"}
      ]
    end
  end
end
