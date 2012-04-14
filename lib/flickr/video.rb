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

    private

    def initialize(hash)
      super
      @video = @info['video']
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
