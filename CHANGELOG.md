# Flickrie changelog

## Version 1.0.0 (Unreleased)

- if you're passing in the content type of the file you're uploading,
  the parameter is now called `:content_type`, not `:mime_type`

## Version 0.7.3

- covered "flickr.people.getPhotos" (I released it as a patch because
  it's important)

## Version 0.7.2

- specified versions of dependencies and Ruby accurately

## Version 0.7.1

- fixed an oauth bug
- added `#hash` method to photos, sets etc. which you can call to get the
  raw data (in Ruby hash). This is useful if I accidentally left something out,
  or if Flickr added something new that I didn't cover yet, that you can
  still get to the data. `#[]` reads from the same hash.

## Version 0.7.0

- covered `flickr.photos.getFavorites` and `flickr.test.login`
- bug fixes (especially regarding the `Flickr::Instance`)

## Version 0.6.1

- `Flickrie::Media::Ticket` is now called just `Flickrie::Ticket`

## Version 0.6.0

- you can access the raw response hash with square brackets, if you notice I
  didn't cover some part of it with methods. So, for example, after calling
  `Flickrie.get_photo_info`, you can get the photo ID by calling `photo['id']`

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
