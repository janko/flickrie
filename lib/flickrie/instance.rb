module Flickrie
  class Instance
    attr_reader :access_token, :access_secret

    def initialize(access_token, access_secret)
      @access_token, @access_secret = access_token, access_secret
    end

    def client
      @client ||= Flickrie.new_client(access_token_hash)
    end

    def upload_client
      @upload_client ||= Flickrie.new_upload_client(access_token_hash)
    end

    include ApiMethods

    private

    def access_token_hash
      {:token => access_token, :secret => access_secret}
    end
  end
end
