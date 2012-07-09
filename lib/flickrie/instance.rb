module Flickrie
  class Instance
    attr_reader :access_token, :access_secret

    def self.delegate(*attributes)
      attributes.each do |attribute|
        define_method(attribute) do
          Flickrie.send(attribute)
        end
      end
    end
    delegate :api_key, :shared_secret, :open_timeout, :timeout, :pagination

    # Initializes a new authenticated instance. Example:
    #
    #     flickrie = Flickrie::Instance.new("ACCESS_TOKEN", "ACCESS_SECRET")
    #     flickrie.find_user_by_email("...")
    def initialize(access_token, access_secret)
      @access_token, @access_secret = access_token, access_secret
    end

    include Callable
    include ApiMethods
  end
end
