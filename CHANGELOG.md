# Flickrie changelog

## Version 1.2.0

- Added 2 new Flickr sizes (`Large 1600` and `Large 2048`).

- The width and height is now back to normal again, Flickr didn't
  mix them up, I did (when a photo is rotated, its width and height
  stay the same). Sorry.

## Version 1.1.2

- Fixed documentation not displaying properly.

## Version 1.1.1

- Excluded unnecessary files from the release (1.4MB => 48KB).
  Sorry :P

## Version 1.1.0

- Before `Flickrie::User` had only the `#public_photos` method, now, I
  just added the missing `#public_videos`, `#public_media`, `#photos`,
  `#videos` and `#media`.

- Fixed Flickr's bug with mixing up the width and the height of a photo
  (not only in the API, but also on their website).

## Version 1.0.2

- Fix some mistakes in the documentation

## Version 1.0.1

- Transfered the documentation to YARD. [Documentation](http://rubydoc.info/gems/flickrie/)

## Version 1.0.0

### Changes that are backwards compatible

- Fixed content type not being passed to the file you're uploading
   if you specified it directly.

- The request will now be retried once more if it timeouts

- In authentication:
** you can now call `request_token.authorize_url` instead of `request_token.get_authorization_url`.
** you can now call `request_token.get_access_token(code)` instead of `Flickrie::OAuth.get_access_token(code, request_token)`.
** you also get the infomation about the user who just authenticated,
    which you can then access with `access_token.user_info`
    (it's a Hash with keys `:fullname`, `:user_nsid` and `:username`)

- When calling `Flickrie.get_photos_counts`, the `Flickrie::MediaCount`
  now also has attributes `#time_interval` (alias for `#date_range`),
  `#from` and `#to`.

### Changes that are NOT backwards compatible

- If you're passing in the content type of the file you're uploading,
  the parameter is now called `:content_type`, not `:mime_type`.

- If there is a problem in obtaining the access token, `Flickrie::Error`
  is now raised, instead of `Flickrie::OAuth::Error`.

- When you're calling `request_token.get_authorization_url`, if you want to
  specifiy permissions, you now have to pass the `:perms` option,
  instead of `:permissions`. In this way you can pass any parameter,
  and it will be appended to the URL (in case Flickr adds a new parameter).

- When you have a `Flickrie::User` instance, the
  `Flickrie::User#time_zone` now returns a struct with `#label` and
  `#offset` attributes (before it returned a `Hash` with those keys).

- When you call `Flickrie.get_media_context`, the result is now a
  struct with attributes `#count`, `#previous`, `#next`.

## Version 0.7.3

- Covered "flickr.people.getPhotos" (I released it as a patch because
  it's important).

## Version 0.7.2

- Specified versions of dependencies and Ruby accurately.

## Version 0.7.1

- Fixed an oauth bug.
- Added `#hash` method to photos, sets etc. which you can call to get the
  raw data (in Ruby hash). This is useful if I accidentally left something out,
  or if Flickr added something new that I didn't cover yet, that you can
  still get to the data. `#[]` reads from the same hash.

## Version 0.7.0

- Covered `flickr.photos.getFavorites` and `flickr.test.login`.
- Bug fixes (especially regarding the `Flickr::Instance`).

## Version 0.6.1

- `Flickrie::Media::Ticket` is now called just `Flickrie::Ticket`.

## Version 0.6.0

- You can access the raw response hash with square brackets, if you notice I
  didn't cover some part of it with methods. So, for example, after calling
  `Flickrie.get_photo_info`, you can get the photo ID by calling `photo['id']`.

- When `Flickrie::Error` is raised, you can now access its `#code`
  attribute. This makes better error handling, because error code
  is (supposed to be) unique, unlike the error message.

## Version 0.5.2

- The gem now also works with Faraday 0.7 (I apologize for not
  making Faraday >= 0.8 a dependency before).

## Version 0.5.1

- Fixed a documentation error.

## Version 0.5.0

- Covered `flickr.photos.getCounts`.
- Covered `flickr.photos.getExif`.

## Version 0.4.1

- Handle file uploads for Rails and Sinatra smarter (see [this wiki](https://github.com/janko-m/flickrie/wiki/Some-tips.md), tip #7)

## Version 0.4.0

- Covered `flickr.photos.getContactsPhotos`.
- Covered `flickr.photos.getContactsPublicPhotos`.
- Covered `flickr.photos.getContext`.
- Implemented uploading photos.
- Covered `flickr.photos.upload.checkTickets`.

## Version 0.3.2

- Enabled passing params to `Flickrie::Set#photos`.

## Version 0.3.1

- Fixed an error when accessing tags from photos fetched through
  certain API calls.

## Version 0.3.0

- The proper error is now raised on wrong access tokens.
- Implemented a better way of using access tokens, using `Flickrie::Instance.new(access_token, access_secret)`
  (see [this wiki](https://github.com/janko-m/flickrie/wiki/Authentication-in-web-applications) for an example).

## Version 0.2.2

- Removed `addressable` gem as a dependency.
