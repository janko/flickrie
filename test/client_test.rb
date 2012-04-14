# encoding: utf-8
require 'test/unit'
require 'flickr/client'
require 'client_fixtures'

class Hash
  def looks_like?(other)
    if keys.sort != other.keys.sort or
       sort.map(&:last).map(&:class) != other.sort.map(&:last).map(&:class)
      return false
    end
    map do |key, value|
      if value.is_a?(self.class)
        if not value.looks_like?(other[key])
          return false
        end
      elsif value.is_a?(Array)
        value.each_with_index do |el, index|
          if el.is_a?(self.class)
            if not el.looks_like?(other[key][index])
              return false
            end
          end
        end
      end
    end
    return true
  end
end

class ClientTest < Test::Unit::TestCase
  def setup
    Flickr.api_key = ENV['FLICKR_API_KEY']
    @client = Flickr.client
  end

  def test_internals
    assert_equal ENV['FLICKR_API_KEY'], Flickr.api_key
    assert_instance_of Flickr::Client, @client
  end

  def test_api_calls
    #license,date_upload,date_taken,owner_name,icon_server,original_format,last_update,geo,tags,machine_tags,o_dims,views,media,path_alias,url_sq,url_q,url_t,url_s,url_n,url_m,url_z,url_c,url_l,url_o
    all_possible_extras = %w[license date_upload date_taken owner_name
      icon_server original_format last_update geo tags machine_tags
      o_dims views media path_alias url_sq url_q url_t url_s url_n url_m
      url_z url_c url_l url_o].join(',')
    response_body = @client.media_from_set(72157629409394888,
      :extras => all_possible_extras).body
    response_body['photoset']['photo'] = response_body['photoset']['photo'].first
    assert response_body.looks_like?(MEDIA_FROM_SET)

    response_body = @client.sets_from_user("67131352@N04").body
    response_body['photosets']['photoset'] = response_body['photosets']['photoset'].first
    assert response_body.looks_like?(SETS_FROM_USER)

    assert @client.find_user_by_email("janko.marohnic@gmail.com").body.looks_like?(FIND_USER)
    assert @client.find_user_by_username("Janko Marohnić").body.looks_like?(FIND_USER)

    assert @client.get_user_info("67131352@N04").body.looks_like?(USER_INFO)
    assert @client.get_set_info(72157629409394888).body.looks_like?(SET_INFO)
    assert @client.get_media_info(6923154272).body.looks_like?(MEDIA_INFO)

    assert @client.get_licenses
  end
end
