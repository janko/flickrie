# Flickrie changelog

## Version 0.6.0

- you can access the raw response hash with square brackets, if you notice I
  didn't cover some part of it with methods. So, for example, `photo['id']`
  will access the photo's ID.

- when `Flickrie::Error` is raised, you can now access its `#code`
  attribute. This makes better error handling, because error code
  is (supposed to be) unique, unlike the error message

## Version 0.5.2

- the gem now also works with Faraday 0.7 (I apologize for not
  making Faraday >= 0.8 a dependency before)

## Version 0.5.1

- fixed a documentation error

## Version 0.5.0

- covered `flickr.photos.getCounts`
- covered `flickr.photos.getExif`

## Version 0.4.1

- handle file uploads for Rails and Sinatra smarter (see [this wiki](https://github.com/janko-m/flickrie/wiki/Some-tips.md), tip #7)

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
