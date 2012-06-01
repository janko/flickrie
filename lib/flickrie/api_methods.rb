require 'flickrie/api_methods/media'
require 'flickrie/api_methods/user'
require 'flickrie/api_methods/set'

module Flickrie
  module ApiMethods
    # For uploading photos and videos to Flickr. Example:
    #
    #     path = File.expand_path("photo.jpg")
    #     photo_id = Flickrie.upload(path, :title => "Me and Jessica", :description => "...")
    #     photo = Flickrie.get_photo_info(photo_id)
    #     photo.title # => "Me and Jessica"
    #
    # If the `:async => 1` option is passed, returns the ticket ID (see {#check\_upload\_tickets}).
    #
    # @param media [File, String] A file or a path to the file you want to upload
    # @param params [Hash] Options for uploading (see [this page](http://www.flickr.com/services/api/upload.api.html))
    # @return [String] New photo's ID, or ticket's ID, if `:async => 1` is passed
    #
    # @note This method requires authentication with "write" permissions.
    def upload(media, params = {})
      response = upload_client.upload(media, params)
      if params[:async] == 1
        response.body['rsp']['ticketid']
      else
        response.body['rsp']['photoid']
      end
    end

    # For replacing photos and videos on Flickr. Example:
    #
    #     path = File.expand_path("photo.jpg")
    #     photo_id = 42374 # ID of the photo to be replaced
    #     id = Flickrie.replace(path, photo_id)
    #
    # If the `:async => 1` option is passed, returns the ticket ID (see {#check\_upload\_tickets}).
    #
    # @param media [File, String] A file or a path to the file you want to upload
    # @param media_id [String, Fixnum] The ID of the photo/video to be replaced
    # @param params [Hash] Options for replacing (see [this page](http://www.flickr.com/services/api/replace.api.html))
    # @return [String] New photo's ID, or ticket's ID, if `:async => 1` is passed
    #
    # @note This method requires authentication with "write" permissions.
    def replace(media, media_id, params = {})
      response = upload_client.replace(media, media_id, params)
      if params[:async] == 1
        response.body['rsp']['ticketid']
      else
        response.body['rsp']['photoid']
      end
    end

    # Fetches upload tickets with given IDs. Example:
    #
    #     photo = File.open("...")
    #     ticket_id = Flickrie.upload(photo, :async => 1)
    #     sleep(10)
    #
    #     ticket = Flickrie.check_upload_tickets(ticket_id)
    #     if ticket.complete?
    #       puts "Photo was uploaded, and its ID is #{ticket.photo_id}"
    #     end
    #
    # @param tickets [String] A space delimited string with ticket IDs
    # @return [Flickrie::Ticket]
    # @api_method [flickr.photos.upload.checkTickets](http://www.flickr.com/services/api/flickr.photos.upload.checkTickets.html)
    def check_upload_tickets(tickets, params = {})
      ticket_ids = tickets.join(',') rescue tickets
      response = client.check_upload_tickets(ticket_ids, params)
      response.body['uploader']['ticket'].
        map { |info| Ticket.new(info) }
    end

    # Fetches all available types of licenses.
    #
    # @return [Array<Flickrie::License>]
    # @api_method [flickr.photos.licenses.getInfo](http://www.flickr.com/services/api/flickr.photos.licenses.getInfo.html)
    def get_licenses(params = {})
      response = client.get_licenses(params)
      License.from_hash(response.body['licenses']['license'])
    end

    # Tests if the authentication was successful. If it was, it
    # returns info of the user who just authenticated.
    #
    # @return [Flickrie::User]
    # @api_method [flickr.test.login](http://www.flickr.com/services/api/flickr.test.login.html)
    #
    # @note This method requires authentication with "read" permissions.
    def test_login(params = {})
      response = client.test_login(params)
      User.from_test(response.body['user'])
    end
  end
end
