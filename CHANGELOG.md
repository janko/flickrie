# Flickrie changelog

## Version 0.4.0

- covered `flickr.photos.getContactsPhotos`
- covered `flickr.photos.getContactsPublicPhotos`
- covered `flickr.photos.getContext`
- implemented uploading photos
- covered `flickr.photos.upload.checkTickets`

## Version 0.3.2

- enabled passing params to `Flickrie::Set#photos`

## Version 0.3.1

- fixed an error when accessing tags from photos fetched through
  certain API calls

## Version 0.3.0

- the proper error is now raised on wrong access tokens
- implemented a better way of using access tokens, using `Flickrie::Instance.new(access_token, access_secret)`
  (see [this wiki](https://github.com/janko-m/flickrie/wiki/Authentication-in-web-applications) for an example)

## Version 0.2.2

- removed `addressable` gem as a dependency
