require 'faraday'

module Flickrie
  class UploadClient < Faraday::Connection
    def upload(media, params = {})
      file = get_file(media, params[:content_type])
      title = file.original_filename.match(/\.\w{3,4}$/).pre_match
      post "upload", {photo: file, title: title}.merge(params)
    end

    def replace(media, media_id, params = {})
      file = get_file(media, params[:content_type])
      title = file.original_filename.match(/\.\w{3,4}$/).pre_match
      post "replace", {photo: file, photo_id: media_id, title: title}.merge(params)
    end

    private

    CONTENT_TYPES = {
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
    }

    def get_file(object, content_type = nil)
      file, content_type, file_path =
        case object.class.name
        when "String"
          # file path
          [File.open(object), content_type || determine_content_type(object), object]
        when "ActionDispatch::Http::UploadedFile"
          # file from Rails
          [object, object.content_type, object.tempfile]
        when "Hash"
          # file from Sinatra
          [object[:tempfile], object[:type], object[:tempfile].path]
        else
          raise Error, "Invalid file format"
        end

      Faraday::UploadIO.new(file, content_type, file_path)
    end

    def determine_content_type(file_path)
      extension = file_path[/\.\w+$/]
      content_type = CONTENT_TYPES.find { |k,v| k.include?(extension) }.last

    rescue NoMethodError
      raise Error, "Content type for this extension (#{extension}) is not known"
    end
  end
end
