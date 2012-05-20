module Flickrie
  class Instance
    attr_reader :access_token, :access_secret

    # Initializes a new authenticated instance. Example:
    #
    #     flickrie = Flickrie::Instance.new("ACCESS_TOKEN", "ACCESS_SECRET")
    #     flickrie.find_user_by_email("...")
    def initialize(access_token, access_secret)
      @access_token, @access_secret = access_token, access_secret
    end

    # See {Flickrie.client} for more info.
    def client
      @client ||= Flickrie.new_client(access_token_hash)
    end

    include ApiMethods

    private

    def upload_client
      @upload_client ||= Flickrie.new_upload_client(access_token_hash)
    end

    def access_token_hash
      {:token => access_token, :secret => access_secret}
    end
  end
end
