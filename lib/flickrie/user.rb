require 'date'

module Flickrie
  class User
    # @!parse attr_reader \
    #   :id, :nsid, :username, :real_name, :location, :description,
    #   :path_alias, :icon_server, :icon_farm, :buddy_icon_url,
    #   :time_zone, :photos_url, :profile_url, :mobile_url,
    #   :first_taken, :favorited_at, :media_count, :pro?, :hash

    # @return [String]
    def id()           @info['id']          end
    # @return [String]
    def nsid()         @info['nsid']        end
    # @return [String]
    def username()     @info['username']    end
    # @return [String]
    def real_name()    @info['realname']    end
    # @return [String]
    def location()     @info['location']    end
    # @return [String]
    def description()  @info['description'] end
    # @return [String]
    def path_alias()   @info['path_alias']  end
    # @return [String]
    def icon_server()  @info['iconserver']  end
    # @return [Fixnum]
    def icon_farm()    @info['iconfarm']    end

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
    def time_zone() Struct.new(:label, :offset).new(*@info['timezone'].values) rescue nil end

    # @return [String]
    def photos_url()  @info['photosurl']  || "http://www.flickr.com/photos/#{nsid || id}" if nsid || id end
    # @return [String]
    def profile_url() @info['profileurl'] || "http://www.flickr.com/people/#{nsid || id}" if nsid || id end
    # @return [String]
    def mobile_url()  @info['mobileurl'] end

    # @return [Time]
    def first_taken() DateTime.parse(@info['photos']['firstdatetaken']).to_time rescue nil end
    # @return [Time]
    def first_uploaded() Time.at(Integer(@info['photos']['firstdate'])) rescue nil end

    # @return [Time]
    def favorited_at() Time.at(Integer(@info['favedate'])) rescue nil end

    # @return [Fixnum]
    def media_count() Integer(@info['photos']['count']) rescue nil end
    alias photos_count media_count
    alias videos_count media_count

    # Same as calling `Flickrie.public_photos_from_user(user.nsid)`.
    #
    # @return [Array<Flickrie::Photo>]
    def public_photos(params = {})
      Flickrie.public_photos_from_user(nsid || id, params)
    end
    # Same as calling `Flickrie.public_videos_from_user(user.nsid)`.
    #
    # @return [Array<Flickrie::Video>]
    def public_videos(params = {})
      Flickrie.public_videos_from_user(nsid || id, params)
    end
    # Same as calling `Flickrie.public_media_from_user(user.nsid)`.
    #
    # @return [Array<Flickrie::Photo, Flickrie::Video>]
    def public_media(params = {})
      Flickrie.public_media_from_user(nsid || id, params)
    end

    # Same as calling `Flickrie.photos_from_user(user.nsid)`.
    #
    # @return [Array<Flickrie::Photo>]
    def photos(params = {})
      Flickrie.photos_from_user(nsid || id, params)
    end
    # Same as calling `Flickrie.videos_from_user(user.nsid)`.
    #
    # @return [Array<Flickrie::Video>]
    def videos(params = {})
      Flickrie.videos_from_user(nsid || id, params)
    end
    # Same as calling `Flickrie.media_from_user(user.nsid)`.
    #
    # @return [Array<Flickrie::Photo, Flickrie::Video>]
    def media(params = {})
      Flickrie.media_from_user(nsid || id, params)
    end

    # @return [Boolean]
    def pro?() Integer(@info['ispro']) == 1 rescue nil end

    def [](key) @info[key] end
    # @return [Hash]
    def hash() @info end

    # The same as calling `Flickrie.get_user_info(user.nsid)`
    #
    # @return [self]
    def get_info(params = {}, info = nil)
      info ||= Flickrie.client.get_user_info(nsid || id, params).body['person']
      @info.update(info)

      %w[username realname location description profileurl
         mobileurl photosurl].each do |attribute|
        @info[attribute] = @info[attribute]['_content']
      end
      %w[count firstdatetaken firstdate].each do |photo_attribute|
        @info['photos'][photo_attribute] = @info['photos'][photo_attribute]['_content']
      end

      self
    end

    private

    def initialize(info = {})
      raise ArgumentError if info.nil?

      @info = info
    end

    def self.from_info(info)
      new.get_info({}, info)
    end

    def self.from_find(info)
      info['username'] = info['username']['_content']
      new(info)
    end

    def self.from_test(info)
      from_find(info)
    end
  end
end
