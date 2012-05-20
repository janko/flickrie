module Flickrie
  class Video
    include Media
    # @!parse attr_reader \
    #   :ready?, :failed?, :pending?, :duration, :width, :height,
    #   :source_url, :download_url, :mobile_download_url

    # @return [Boolean]
    def ready?()   Integer(@video['ready']) == 1   rescue nil end
    # @return [Boolean]
    def failed?()  Integer(@video['failed']) == 1  rescue nil end
    # @return [Boolean]
    def pending?() Integer(@video['pending']) == 1 rescue nil end

    # @return [Fixnum]
    def duration() Integer(@video['duration']) rescue nil end

    # @return [Fixnum]
    def width()  Integer(@video['width'])  rescue nil end
    # @return [Fixnum]
    def height() Integer(@video['height']) rescue nil end

    # @return [String]
    def source_url()          @video['source_url']          end
    # @return [String]
    def download_url()        @video['download_url']        end
    # @return [String]
    def mobile_download_url() @video['mobile_download_url'] end

    # This fetches the {#source\_url}, {#download\_url} and the {#mobile\_download\_url}
    #
    # @return [self]
    def get_sizes(params = {}, info = nil)
      info ||= Flickrie.client.get_media_sizes(id, params).body['sizes']
      @info['usage'] ||= {}
      @info['usage'].update \
        'canblog'     => info['canblog'],
        'canprint'    => info['canprint'],
        'candownload' => info['candownload']
      info['size'].each do |hash|
        case hash['label']
        when 'Video Player' then @video['source_url'] = hash['source']
        when 'Site MP4'     then @video['download_url'] = hash['source']
        when 'Mobile MP4'   then @video['mobile_download_url'] = hash['source']
        end
      end

      self
    end

    # Same as calling `Flickrie.get_video_info(video.id)`.
    #
    # @return [self]
    def get_info(params = {}, info = nil)
      super
      @video = @info['video']

      self
    end

    private

    def initialize(info = {})
      super
      @video = {}
    end
  end
end
