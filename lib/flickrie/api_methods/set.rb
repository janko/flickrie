module Flickrie
  module ApiMethods
    # Fetches information about the set with the given ID.
    #
    # @param set_id [String, Fixnum]
    # @return [Flickrie::Set]
    # @api_method [flickr.photosets.getInfo](http://www.flickr.com/services/api/flickr.photosets.getInfo.html)
    def get_set_info(set_id, params = {})
      response = client.get_set_info(set_id, params)
      Set.from_info(response.body['photoset'])
    end

    # Fetches sets from a user with the given NSID.
    #
    # @param nsid [String]
    # @return [Flickrie::Collection<Flickrie::Set>]
    # @api_method [flickr.photosets.getList](http://www.flickr.com/services/api/flickr.photosets.getList.html)
    def sets_from_user(nsid, params = {})
      response = client.sets_from_user(nsid, params)
      Set.from_user(response.body['photosets'], nsid)
    end
  end
end
