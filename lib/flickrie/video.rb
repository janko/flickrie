module Flickrie
  class Video
    include Media

    # @!parse attr_reader :ready?
    def ready?()   Integer(@video['ready']) == 1   rescue nil end
    # @!parse attr_reader :failed?
    def failed?()  Integer(@video['failed']) == 1  rescue nil end
    # @!parse attr_reader :pending?
    def pending?() Integer(@video['pending']) == 1 rescue nil end

    # @!parse attr_reader :duration
    def duration() Integer(@video['duration']) rescue nil end

    # @!parse attr_reader :width
    def width()  Integer(@video['width'])  rescue nil end
    # @!parse attr_reader :height
    def height() Integer(@video['height']) rescue nil end

    # @!parse attr_reader :source_url
    def source_url()          @video['source_url']          end
    # @!parse attr_reader :download_url
    def download_url()        @video['download_url']        end
    # @!parse attr_reader :mobile_download_url
    def mobile_download_url() @video['mobile_download_url'] end

    # This fetches the {#source\_url}, {#download\_url} and the {#mobile\_download\_url}
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
