require 'date'

module Flickrie
  class User
    def id()           @info['id']          end
    def nsid()         @info['nsid']        end
    def username()     @info['username']    end
    def real_name()    @info['realname']    end
    def location()     @info['location']    end
    def time_zone()    @info['timezone']    end
    def description()  @info['description'] end
    def profile_url()  @info['profileurl']  end
    def mobile_url()   @info['mobileurl']   end
    def photos_url()   @info['photosurl']   end
    def path_alias()   @info['path_alias']  end
    def icon_server()  @info['iconserver']  end
    def icon_farm()    @info['iconfarm']    end

    def buddy_icon_url
      if icon_farm
        if icon_server.to_i > 0
          "http://farm{#{icon_farm}}.staticflickr.com/{#{icon_server}}/buddyicons/#{nsid}.jpg"
        else
          "http://www.flickr.com/images/buddyicon.jpg"
        end
      end
    end

    def first_taken
      if @info['photos'] and @info['photos']['firstdatetaken']
        DateTime.parse(@info['photos']['firstdatetaken']).to_time
      end
    end

    def first_uploaded
      if @info['photos'] and @info['photos']['firstdate']
        Time.at(@info['photos']['firstdate'].to_i)
      end
    end

    def media_count
      if @info['photos'] and @info['photos']['count']
        @info['photos']['count'].to_i
      end
    end

    def public_photos() Flickrie.public_photos_from_user(nsid) end

    def pro?
      @info['ispro'].to_i == 1 if @info['ispro']
    end

    def [](key)
      @info[key]
    end

    def get_info(info = nil)
      info ||= Flickrie.client.get_user_info(nsid).body['person']
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
      new.get_info(info)
    end

    def self.from_find(info)
      info['username'] = info['username']['_content']
      new(info)
    end
  end
end
