require 'flickr/media'

module Flickr
  class Video
    include Media

    def ready?;   @video['ready'].to_i == 1   end
    def failed?;  @video['failed'].to_i == 1  end
    def pending?; @video['pending'].to_i == 1 end

    def duration; @video['duration'].to_i end

    def width;  @video['width'].to_i  end
    def height; @video['height'].to_i end

    def source_url;          @video['source_url']          end
    def download_url;        @video['download_url']        end
    def mobile_download_url; @video['mobile_download_url'] end

    def get_sizes(info = nil)
      info ||= Flickr.client.get_item_sizes(id).body['sizes']
      unless @info['usage']
        @info['usage'] = {
          'canblog'     => info['canblog'],
          'canprint'    => info['canprint'],
          'candownload' => info['candownload']
        }
      end
      info['size'].each do |hash|
        case hash['label']
        when 'Video Player' then @video['source_url'] = hash['source']
        when 'Site MP4' then @video['download_url'] = hash['source']
        when 'Mobile MP4' then @video['mobile_download_url'] = hash['source']
        end
      end

      self
    end

    private

    def initialize(hash)
      super
      @video = @info['video']

    def self.from_sizes(info)
      new.get_sizes(info)
    end
  end
end

__END__

{
  ...
  "video"=>
   {"ready"=>1,
    "failed"=>0,
    "pending"=>0,
    "duration"=>"34",
    "width"=>"480",
    "height"=>"360"}
}
