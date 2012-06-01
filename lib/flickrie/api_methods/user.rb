module Flickrie
  module ApiMethods
    # Fetches the Flickr user with the given email.
    #
    # @param email [String]
    # @return [Flickrie::User]
    # @api_method [flickr.people.findByEmail](http://www.flickr.com/services/api/flickr.people.findByEmail.html)
    def find_user_by_email(email, params = {})
      response = client.find_user_by_email(email, params)
      User.from_find(response.body['user'])
    end

    # Fetches the Flickr user with the given username.
    #
    # @param username [String]
    # @return [Flickrie::User]
    # @api_method [flickr.people.findByUsername](http://www.flickr.com/services/api/flickr.people.findByUsername.html)
    def find_user_by_username(username, params = {})
      response = client.find_user_by_username(username, params)
      User.from_find(response.body['user'])
    end

    # Fetches the Flickr user with the given NSID.
    #
    # @param nsid [String]
    # @return [Flickrie::User]
    # @api_method [flickr.people.getInfo](http://www.flickr.com/services/api/flickr.people.getInfo.html)
    def get_user_info(nsid, params = {})
      response = client.get_user_info(nsid, params)
      User.from_info(response.body['person'])
    end

    # Returns the upload status of the user who is currently authenticated.
    #
    # @return [Flickrie::User]
    # @api_method [flickr.people.getUploadStatus](http://www.flickr.com/services/api/flickr.people.getUploadStatus.html)
    # @see Flickrie::User#upload_status
    #
    # @note This method requires authentication with "read" permissions.
    def get_upload_status(params = {})
      response = client.get_upload_status(params)
      User.from_upload_status(response.body['user'])
    end
  end
end
