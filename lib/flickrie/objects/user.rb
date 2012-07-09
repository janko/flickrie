require 'date'
require 'flickrie/objects/user/upload_status'

module Flickrie
  class User
    # @!parse attr_reader \
    #   :id, :nsid, :username, :real_name, :location, :description,
    #   :path_alias, :icon_server, :icon_farm, :buddy_icon_url,
    #   :time_zone, :photos_url, :profile_url, :mobile_url,
    #   :first_taken, :favorited_at, :media_count, :pro?, :hash,
    #   :upload_status

    # @return [String]
    def id()           @hash['id']          end
    # @return [String]
    def nsid()         @hash['nsid']        end
    # @return [String]
    def username()     @hash['username']    end
    # @return [String]
    def real_name()    @hash['realname']    end
    # @return [String]
    def location()     @hash['location']    end
    # @return [String]
    def description()  @hash['description'] end
    # @return [String]
    def path_alias()   @hash['path_alias']  end
    # @return [String]
    def icon_server()  @hash['iconserver']  end
    # @return [Fixnum]
    def icon_farm()    @hash['iconfarm']    end

    # @return [String]
    def buddy_icon_url
      if icon_farm
        if icon_server.to_i > 0 && (nsid || id)
          "http://farm{#{icon_farm}}.staticflickr.com/{#{icon_server}}/buddyicons/#{nsid || id}.jpg"
        else
          "http://www.flickr.com/images/buddyicon.jpg"
        end
      end
    end

    # Returns the time zone of the user. Example:
    #
    #     user.time_zone.offset # => "+01:00"
    #     user.time_zone.label  # => "Sarajevo, Skopje, Warsaw, Zagreb"
    #
    # @return [Struct]
    def time_zone() Struct.new(:label, :offset).new(*@hash['timezone'].values) rescue nil end

    # @return [String]
    def photos_url()  @hash['photosurl']  || "http://www.flickr.com/photos/#{nsid || id}" if nsid || id end
    # @return [String]
    def profile_url() @hash['profileurl'] || "http://www.flickr.com/people/#{nsid || id}" if nsid || id end
    # @return [String]
    def mobile_url()  @hash['mobileurl'] end

    # @return [Time]
    def first_taken() DateTime.parse(@hash['photos']['firstdatetaken']).to_time rescue nil end
    # @return [Time]
    def first_uploaded() Time.at(Integer(@hash['photos']['firstdate'])) rescue nil end

    # @return [Time]
    def favorited_at() Time.at(Integer(@hash['favedate'])) rescue nil end

    # @return [Fixnum]
    def media_count() Integer(@hash['photos']['count']) rescue nil end
    alias photos_count media_count
    alias videos_count media_count

    # Same as calling `Flickrie.public_photos_from_user(user.nsid)`.
    #
    # @return [Flickrie::Collection<Flickrie::Photo>]
    def public_photos(params = {})
      @api_caller.public_photos_from_user(nsid || id, params)
    end
    # Same as calling `Flickrie.public_videos_from_user(user.nsid)`.
    #
    # @return [Flickrie::Collection<Flickrie::Video>]
    def public_videos(params = {})
      @api_caller.public_videos_from_user(nsid || id, params)
    end
    # Same as calling `Flickrie.public_media_from_user(user.nsid)`.
    #
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    def public_media(params = {})
      @api_caller.public_media_from_user(nsid || id, params)
    end

    # Same as calling `Flickrie.photos_from_user(user.nsid)`.
    #
    # @return [Flickrie::Collection<Flickrie::Photo>]
    def photos(params = {})
      @api_caller.photos_from_user(nsid || id, params)
    end
    # Same as calling `Flickrie.videos_from_user(user.nsid)`.
    #
    # @return [Flickrie::Collection<Flickrie::Video>]
    def videos(params = {})
      @api_caller.videos_from_user(nsid || id, params)
    end
    # Same as calling `Flickrie.media_from_user(user.nsid)`.
    #
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    def media(params = {})
      @api_caller.media_from_user(nsid || id, params)
    end

    # @return [Boolean]
    def pro?() Integer(@hash['ispro']) == 1 rescue nil end

    # Returns the upload status of the user.
    #
    # @return [Flickrie::User::UploadStatus]
    def upload_status() UploadStatus.new(@hash['upload_status']) rescue nil end

    def [](key) @hash[key] end
    # @return [Hash]
    def hash() @hash end

    # The same as calling `Flickrie.get_user_info(user.nsid)`
    #
    # @return [self]
    def get_info(params = {})
      @hash.deep_merge!(@api_caller.get_user_info(nsid || id, params).hash)
      self
    end

    private

    def initialize(hash, api_caller)
      @hash = hash
      @api_caller = api_caller
    end
  end
end
