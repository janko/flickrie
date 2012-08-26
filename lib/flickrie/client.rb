require 'faraday'

module Flickrie
  class Client < Faraday::Connection
    [:get, :post].each do |http_method|
      define_method(http_method) do |flickr_method, params = {}|
        # (include_sizes: true) --> (extras: "url_sq,url_q,url_s,...")
        if params.delete(:include_sizes)
          urls = Photo::FLICKR_SIZES.values.map { |s| "url_#{s}" }.join(',')
          params[:extras] = [params[:extras], urls].compact.join(',')
        end

        super() do |req|
          req.params[:method] = flickr_method
          req.params.update(params)
        end
      end
    end

    def method_missing(name, *args, &block)
      [
        name.to_s.sub(/media|photos?|videos?/, "(photos|videos|media)"),
        name.to_s.sub(/media|photos?|videos?/, "(photo|video|media)"),
        name.to_s.sub(/media|photos?|videos?/, "(photo|video)")
      ].
        each do |method_name|
          if flickr_method = FLICKR_API_METHODS.invert[method_name]
            http_method, params = methods[flickr_method]
            return send(http_method, flickr_method, params.call(*args))
          end
        end

      super
    end
  end
end

require "flickrie/client/methods"
