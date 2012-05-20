require 'date'

module Flickrie
  class User
    # @!parse attr_reader :id
    def id()           @info['id']          end
    # @!parse attr_reader :nsid
    def nsid()         @info['nsid']        end
    # @!parse attr_reader :username
    def username()     @info['username']    end
    # @!parse attr_reader :real_name
    def real_name()    @info['realname']    end
    # @!parse attr_reader :location
    def location()     @info['location']    end
    # @!parse attr_reader :description
    def description()  @info['description'] end
    # @!parse attr_reader :path_alias
    def path_alias()   @info['path_alias']  end
    # @!parse attr_reader :icon_server
    def icon_server()  @info['iconserver']  end
    # @!parse attr_reader :icon_farm
    def icon_farm()    @info['iconfarm']    end

    # @!parse attr_reader :buddy_icon_url
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
    # @!parse attr_reader :time_zone
    def time_zone() Struct.new(:label, :offset).new(*@info['timezone'].values) rescue nil end

    # @!parse attr_reader :photos_url
    def photos_url()  @info['photosurl']  || "http://www.flickr.com/photos/#{nsid || id}" end
    # @!parse attr_reader :profile_url
    def profile_url() @info['profileurl'] || "http://www.flickr.com/people/#{nsid || id}" end
    # @!parse attr_reader :mobile_url
    def mobile_url()  @info['mobileurl'] end

    # @!parse attr_reader :first_taken
    def first_taken() DateTime.parse(@info['photos']['firstdatetaken']).to_time rescue nil end
    # @!parse attr_reader :first_uploaded
    def first_uploaded() Time.at(Integer(@info['photos']['firstdate'])) rescue nil end

    # @!parse attr_reader :favorited_at
    def favorited_at() Time.at(Integer(@info['favedate'])) rescue nil end

    # @!parse attr_reader :media_count
    def media_count() Integer(@info['photos']['count']) rescue nil end
    alias photos_count media_count
    alias videos_count media_count

    # @comment TODO: public videos, media and without public
    # The same as calling `Flickrie.public_photos_from_user(user.nsid)`
    def public_photos(params = {}) Flickrie.public_photos_from_user(nsid || id, params) end

    # @!parse attr_reader :pro?
    def pro?() Integer(@info['ispro']) == 1 rescue nil end

    def [](key) @info[key] end
    # @!parse attr_reader :hash
    def hash() @info end

    # The same as calling `Flickrie.get_user_info(user.nsid)`
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
