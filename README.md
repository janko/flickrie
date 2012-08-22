# Flickrie

This gem is a nice wrapper for the Flickr API with an object-oriented interface.

- Homepage: [http://janko-m.github.com/flickrie/](http://janko-m.github.com/flickrie/)

- GitHub page: [https://github.com/janko-m/flickrie](https://github.com/janko-m/flickrie)

- Documentation: [http://rubydoc.info/github/janko-m/flickrie/master](http://rubydoc.info/github/janko-m/flickrie/master)

- Wiki: [https://github.com/janko-m/flickrie/wiki](https://github.com/janko-m/flickrie/wiki)

- Flickr API page: [http://www.flickr.com/services/api](http://www.flickr.com/services/api/)

Supported Ruby versions:

- `1.9.2`
- `1.9.3`

This gem follows [Semantic versioning](http://semver.org/).

## Installation and setup

Add it to your `Gemfile`.

```ruby
gem "flickrie"
```

And in your Terminal run `bundle install`.

Now you have to set your API key and shared secret in your app (if you don't have them yet,
you can get them [here](http://www.flickr.com/services/apps/create/apply)).

```ruby
require 'flickrie'

Flickrie.api_key = "API_KEY"
Flickrie.shared_secret = "SHARED_SECRET"
```

If you're in a Rails app, this would go into an initializer.

## Usage

```ruby
set_id = 819234
photos = Flickrie.photos_from_set(set_id) # => [#<Photo: id="8232348", ...>, #<Photo: id="8194318", ...>, ...]

photo = photos.first
photo.id          # => "8232348"
photo.url         # => "http://www.flickr.com/photos/67313352@N04/8232348"
photo.title       # => "Samantha and me"
photo.owner       # => #<User: nsid="67313352@N04", ...>
photo.owner.nsid  # => "67313352@N04"
```

You can also pass in additional parameters to to get more information about photos:

```ruby
photos = Flickrie.photos_from_set(819234, extras: "owner_name,last_update,tags,views")

photo = photos.first
photo.tags.join(" ") # => "cave cold forrest"
photo.owner.username # => "jsmith"
photo.updated_at     # => 2012-04-20 23:29:17 +0200
photo.views_count    # => 24
```

For the list of all Flickr API methods and parameters you can pass to them take a look at the
[Flickr API documentation](http://www.flickr.com/services/api/). The method names in this gem correspond
to Flickr's method names (so, for example, `Flickr.photos_from_set` is actually `flickr.photosets.getPhotos`).

You can also get additional info on a single photo:

```ruby
photo = Flickrie.get_photo_info(8232348)

photo.description           # => "In this photo, Samantha and me found a secret tunnel..."
photo.comments_count        # => 6
photo.visibility.public?    # => true
photo.can_download?         # => true
photo.owner.real_name       # => "John Smith"
photo.location.country.name # => "United States"
```

If you already have an instatiated photo, you can also get info like this:

```ruby
photo.description # => nil
photo.get_info
photo.description # => "In this photo Peter said something really funny..."
```

You'll also probably want to display these photos in your app. There are
some neat methods to help you with this.

```ruby
photo = Flickrie.get_photo_sizes(8232348)
# or `photo.get_sizes` on an existing photo

photo.medium!(500)
photo.size       # => "Medium 500"
photo.source_url # => "http://farm8.staticflickr.com/7090/7093101501_9337f28800.jpg"
photo.width      # => 375
photo.height     # => 500

photo.available_sizes # => ["Square 75", "Thumbnail", "Square 150", "Small 240", "Small 320", "Medium 500"]
```

So, in your ERB template you could do something like this (in Rails):

```erb
<%= image_tag photo.source_url, :size => "#{photo.width}x#{photo.height}" %>
```

You can see the full list of available methods and attributes in the
[documentation](http://rubydoc.info/gems/flickrie/).

Also, be sure to check the [wiki](https://github.com/janko-m/flickrie/wiki) for some additional info and tips.

## Authentication

```ruby
require 'flickrie'

Flickrie.api_key = "API_KEY"
Flickrie.shared_secret = "SHARED_SECRET"

request_token = Flickrie::OAuth.get_request_token
url = request_token.authorize_url
puts "Visit this url to authenticate: #{url}"

print "If you agreed, the code was displayed afterwards. Enter it: "
code = gets.strip
access_token = request_token.get_access_token(code)
puts "You successfully authenticated!"

Flickrie.access_token = access_token.token
Flickrie.access_secret = access_token.secret
access_token.user_params # => {fullname: "John Smith", user_nsid: "67131352@N03", username: "jsmith"}
```

When getting the authorization url, you can also call
```ruby
request_token.authorize_url(permissions: "read")
```
to ask only for "read" permissions. Available permissions are "read", "write" and "delete".

If you want to make authentication in your web application, I would highly
recommend the [omniauth-flickr](https://github.com/timbreitkreutz/omniauth-flickr) gem.
Or, if you want to do it from scratch, without any additional gems, check out
[this wiki](https://github.com/janko-m/flickrie/wiki/Authentication-in-web-applications)
for an example how that authentication might look like.

## Photo upload

```ruby
photo_id = Flickrie.upload("/path/to/photo.jpg", title: "A cow")
photo = Flickrie.get_photo_info(photo_id)
photo.title # => "A cow"
```

For the list of parameters you can pass in when uploading a photo, see
[this page](http://www.flickr.com/services/api/upload.api.html).

Note that photo uploads require authentication with "write" permissions.

See [this wiki](https://github.com/janko-m/flickrie/wiki/Asynchronous-photo-upload) for an example
of an asynchronous photo upload.

## A few words

Now, there are a lot more API methods that I didn't cover yet,
but I'll constantly update this gem with new API methods. For all of the methods
I didn't cover, you can still call them using

```ruby
Flickrie.client.get(method_name, params = {})
Flickrie.client.post(method_name, params = {})
```

For example:

```ruby
response = Flickrie.client.get "flickr.photos.getContext", :photo_id => 2842732

reponse.body # =>
# {
#   "count" => {"_content" => 99},
#   "prevphoto" => {
#     "id" => "6946978706",
#     "secret" => "b38270bbd6",
#     ...
#   }
#   "nextphoto" => {
#     "id" => "6946979704",
#     "secret" => "74513ff732",
#     ...
#   }
# }
response.body['prevphoto']['id'] # => "6946978706"
```

It's not nearly as pretty, but at least you can get to the data for the
time being. Notice that the `:api_key` parameter is always passed in by
default.

## Issues

Please, feel free to post any issues that you're having. You can also
post feature requests.

## Cedits

Special thanks to @**mislav**, my brother, he helped me really a lot
with getting started with Ruby, and with the basis of this gem.

## Changelog

You can see the changelog [here](https://github.com/janko-m/flickrie/blob/master/CHANGELOG.md).

## Social

You can follow me on Twitter, I'm [@m_janko](https://twitter.com/m_janko).

## Currently covered API methods

```ruby
# people
"flickr.people.findByEmail"             -> Flickrie.find_user_by_email
"flickr.people.findByUsername"          -> Flickrie.find_user_by_username
"flickr.people.getInfo"                 -> Flickrie.get_user_info
"flickr.people.getPhotos"               -> Flickrie.photos_from_user
"flickr.people.getPhotosOf"             -> Flickrie.photos_of_user
"flickr.people.getPublicPhotos"         -> Flickrie.public_photos_from_user
"flickr.people.getUploadStatus"         -> Flickrie.get_upload_status

# photos
"flickr.photos.addTags"                 -> Flickrie.add_photo_tags
"flickr.photos.delete"                  -> Flickrie.delete_photo
"flickr.photos.getContactsPhotos"       -> Flickrie.photos_from_contacts
"flickr.photos.getContactsPublicPhotos" -> Flickrie.public_photos_from_user_contacts
"flickr.photos.getContext"              -> Flickrie.get_photo_context
"flickr.photos.getCounts"               -> Flickrie.get_photos_counts
"flickr.photos.getExif"                 -> Flickrie.get_photo_exif
"flickr.photos.getFavorites"            -> Flickrie.get_photo_favorites
"flickr.photos.getInfo"                 -> Flickrie.get_photo_info
"flickr.photos.getNotInSet"             -> Flickrie.photos_not_in_set
"flickr.photos.getPerms"                -> Flickrie.get_photo_permissions
"flickr.photos.getRecent"               -> Flickrie.get_recent_photos
"flickr.photos.getSizes"                -> Flickrie.get_photo_sizes
"flickr.photos.getUntagged"             -> Flickrie.get_untagged_photos
"flickr.photos.getWithGeoData"          -> Flickrie.get_photos_with_geo_data
"flickr.photos.getWithoutGeoData"       -> Flickrie.get_photos_without_geo_data
"flickr.photos.recentlyUpdated"         -> Flickrie.recently_updated_photos
"flickr.photos.removeTag"               -> Flickrie.remove_photo_tag
"flickr.photos.search"                  -> Flickrie.search_photos
"flickr.photos.setContentType"          -> Flickrie.set_photo_content_type
"flickr.photos.setDates"                -> Flickrie.set_photo_dates
"flickr.photos.setMeta"                 -> Flickrie.set_photo_meta
"flickr.photos.setPerms"                -> Flickrie.set_photo_permissions
"flickr.photos.setSafetyLevel"          -> Flickrie.set_photo_safety_level
"flickr.photos.setTags"                 -> Flickrie.set_photo_tags

# photos.licenses
"flickr.photos.licenses.getInfo"        -> Flickrie.get_licenses
"flickr.photos.licenses.setLicense"     -> Flickrie.set_photo_license

# photos.upload
"flickr.photos.upload.checkTickets"     -> Flickrie.check_upload_tickets

# photosets
"flickr.photosets.addPhoto"             -> Flickrie.add_photo_to_set
"flickr.photosets.create"               -> Flickrie.create_set
"flickr.photosets.delete"               -> Flickrie.delete_set
"flickr.photosets.editMeta"             -> Flickrie.edit_set_metadata
"flickr.photosets.editPhotos"           -> Flickrie.edit_set_photos
"flickr.photosets.getContext"           -> Flickrie.get_set_context
"flickr.photosets.getInfo"              -> Flickrie.get_set_info
"flickr.photosets.getList"              -> Flickrie.sets_from_user
"flickr.photosets.getPhotos"            -> Flickrie.photos_from_set
"flickr.photosets.orderSets"            -> Flickrie.order_sets
"flickr.photosets.removePhoto"          -> Flickrie.remove_photos_from_set
"flickr.photosets.removePhotos"         -> Flickrie.remove_photos_from_set
"flickr.photosets.reorderPhotos"        -> Flickrie.reorder_photos_in_set
"flickr.photosets.setPrimaryPhoto"      -> Flickrie.set_primary_photo_to_set

# test
"flickr.test.login"                     -> Flickrie.test_login
```

## License

[MIT](https://github.com/janko-m/flickrie/blob/master/LICENSE)
