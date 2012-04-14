require 'flickr/client'
require 'date'

module Flickr
  class User
    def id;           @info['id']                   end
    def nsid;         @info['nsid']                 end
    def username;     @info['username']             end
    def real_name;    @info['realname']             end
    def location;     @info['location']             end
    def description;  @info['description']          end
    def profile_url;  @info['profileurl']           end
    def mobile_url;   @info['mobileurl']            end
    def photos_url;   @info['photosurl']            end
    def path_alias;   @info['path_alias']           end

    def buddy_icon_url
      if @info['iconserver']
        if @info['iconserver'].to_i > 0
          icon_farm, icon_server = info['iconfarm'], info['iconserver']
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

    def photos_count
      if @info['photos'] and @info['photos']['count']
        @info['photos']['count'].to_i
      end
    end

    def pro?
      @info['ispro'].to_i == 1 if @info['ispro']
    end

    def get_info(info = nil)
      info ||= Flickr.client.get_user_info(nsid)
      @info.update(info)

      # Fixes
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
      @info = info
    end

    def self.from_info(info)
      new('nsid' => info['nsid']).get_info(info)
    end
  end
end
