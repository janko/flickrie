module Flickrie
  class Video
    include Media

    def ready?()   @video['ready'].to_i == 1 if @video['ready']     end
    def failed?()  @video['failed'].to_i == 1 if @video['failed']   end
    def pending?() @video['pending'].to_i == 1 if @video['pending'] end

    def duration() @video['duration'].to_i if @video['duration'] end

    def width()  @video['width'].to_i if @video['width']   end
    def height() @video['height'].to_i if @video['height'] end

    def source_url()          @video['source_url']          end
    def download_url()        @video['download_url']        end
    def mobile_download_url() @video['mobile_download_url'] end

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
