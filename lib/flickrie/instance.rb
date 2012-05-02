module Flickrie
  class Instance
    attr_reader :access_token, :access_secret

    def initialize(access_token, access_secret)
      @access_token, @access_secret = access_token, access_secret
    end

    def client
      Flickrie.client(:token => access_token, :secret => access_secret)
    end

    include ApiMethods
  end
end
