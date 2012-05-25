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

    # This fetches the {#source\_url}, {#download\_url} and the {#mobile\_download\_url}.
    # Same as calling `Flickrie.get_video_sizes(video.id)`
    #
    # @return [self]
    def get_sizes(params = {})
      hash = Flickrie.client.get_media_sizes(id, params).body['sizes']
      self.class.fix_sizes(hash)
      @hash.deep_merge!(hash)
      @video = @hash['video']

      self
    end

    # Same as calling `Flickrie.get_video_info(video.id)`.
    #
    # @return [self]
    def get_info(params = {})
      super
      @video = @hash['video']

      self
    end

    private

    def initialize(hash = {})
      super
      @video = hash['video'] || {}
    end

    def self.fix_sizes(hash)
      hash['usage'] = {
        'canblog'     => hash['canblog'],
        'canprint'    => hash['canprint'],
        'candownload' => hash['candownload']
      }
      hash['video'] ||= {}
      hash['size'].each do |info|
        case info['label']
        when 'Video Player' then hash['video']['source_url'] = info['source']
        when 'Site MP4'     then hash['video']['download_url'] = info['source']
        when 'Mobile MP4'   then hash['video']['mobile_download_url'] = info['source']
        end
      end
    end
  end
end
