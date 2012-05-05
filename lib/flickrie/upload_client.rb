module Flickrie
  class << self
    def upload_client(access_token_hash = {})
      @upload_client ||= UploadClient.new(upload_params) do |conn|
        conn.request :oauth,
          :consumer_key => api_key,
          :consumer_secret => shared_secret,
          :token => access_token_hash[:token] || access_token,
          :token_secret => access_token_hash[:secret] || access_secret
        conn.request :multipart

        conn.use UploadStatusCheck
        conn.response :xml

        conn.adapter Faraday.default_adapter
      end
    end

    private

    def upload_params
      {
        :url => 'http://api.flickr.com/services',
        :request => {
          :open_timeout => open_timeout || OPEN_TIMEOUT
        }
      }
    end
  end

  class UploadStatusCheck < Faraday::Response::Middleware
    def on_complete(env)
      if env[:body]['rsp']['stat'] != 'ok'
        raise Error, env[:body]['rsp']['err']['msg']
      end
    end
  end

  class UploadClient < Faraday::Connection
    def upload(media, params = {})
      media_file = get_file(media, params[:mime_type])
      post "upload", {:photo => media_file}.merge(params)
    end

    def replace(media, media_id, params = {})
      media_file = get_file(media)
      post "replace", {:photo => media_file,
                       :photo_id => media_id}.merge(params)
    end

    private

    MIME_TYPES = {
      %w[.jpg .jpeg .jpe .jif .jfif .jfi] => 'image/jpeg',
      %w[.gif]                            => 'image/gif',
      %w[.png]                            => 'image/png',
      %w[.svg .svgz]                      => 'image/svg+xml',
      %w[.tiff .tif]                      => 'image/tiff',
      %w[.ico]                            => 'image/vnd.microsoft.icon',

      %w[.mpg .mpeg .m1v .m1a .m2a .mpa .mpv] => 'video/mpeg',
      %w[.mp4 .m4a .m4p .m4b .m4r .m4v]       => 'video/mp4',
      %w[.ogv .oga .ogx .ogg .spx]            => 'video/ogg',
      %w[.mov .qt]                            => 'video/quicktime',
      %w[.webm]                               => 'video/webm',
      %w[.mkv .mk3d .mka .mks]                => 'video/x-matroska',
      %w[.wmv]                                => 'video/x-ms-wmv',
      %w[.flv .f4v .f4p .f4a .f4b]            => 'video/x-flv',
      %w[.avi]                                => 'video/avi'
    }.freeze

    def get_file(object, mime_type = nil)
      if object.is_a?(String)
        Faraday::UploadIO.new(object, mime_type || get_mime_type(object))
      else
        object
      end
    end

    def get_mime_type(file_path)
      extension = file_path[/\.\w{3,4}$/]
      mime_type = MIME_TYPES.find { |k,v| k.include?(extension) }.last

    rescue NoMethodError
      raise Error, "Don't know mime type for this extension (#{extension})"
    end
  end
end
