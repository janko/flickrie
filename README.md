# Flickrie

This gem is a nice wrapper for the Flickr API with an object-oriented interface.

- GitHub page: [https://github.com/janko-m/flickrie](https://github.com/janko-m/flickrie)

- Documentation: [http://rubydoc.info/github/janko-m/flickrie](http://rubydoc.info/github/janko-m/flickrie/)

- Wiki: [https://github.com/janko-m/flickrie/wiki](https://github.com/janko-m/flickrie/wiki)

- Flickr API page: [http://www.flickr.com/services/api](http://www.flickr.com/services/api/)

## About

The reason why I did this gem is because the existing ones either weren't
well maintained, or they weren't object oriented and provided a literal
wrapper over the API. That didn't statisfy me, because Flickr API
sometimes gives you the same information in different ways. And I want
to normalize that. Also, JSON responses can return "time" attributes
only in the string format. And I thought it would be nice that, if you're
accessing the `updated_at` attribute for example, you actually **get**
an instance of `Time`, instead of a string, or even integer. These are
just some of the reason I decided to make this gem.

The method names here aren't called the same as Flickr's API methods
(and they can't be), but they follow a pattern which
shouldn't be too difficult to predict. Take a look at the ["Currently covered API
methods"](#currently-covered-api-methods) section of this readme.

Also, some attribute names that you get from the response are changed.
So, for example, the `last_update` attribute is called `updated_at`,
and the `candownload` attribute is called `can_download?`. Because this
is a **ruby** wrapper, I wanted to write it in Ruby/Rails fashion. At
first you might not approve of this, because then you might not know
what the methods name are if you know the name of the key in the
response hash. But, on the other hand, Flickr often gives you the same
information in different formats, so this also acts as a normalizer. The
downsize of this approach is that it may not be up to date when the
Flickr API changes, but that's why I have **you** to open a new issue
when you notice something isn't working :)

The gem works on Ruby versions `1.9.2` and `1.9.3`. Also, it follows
[Semantic versioning](http://semver.org/).

## Examples of usage

You first need to install the gem.

```
[sudo] gem install flickrie
```

Then, if you're using Bundler in your project, put it into your `Gemfile`:

```ruby
gem "flickrie", "~> 1.4"
```

Then in your app you set the API key and shared secret (if you don't have them
already, you can apply for them [here](http://www.flickr.com/services/apps/create/apply)).

```ruby
require 'flickrie'

Flickrie.api_key = "API_KEY"
Flickrie.shared_secret = "SHARED_SECRET"
```

If your in Rails, it's a good idea to put this into an initializer.

Now you can search for stuff.

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

You can also throw in some parameters to `Flickrie.photos_from_set` to get more information about photos. For example,

```ruby
photos = Flickrie.photos_from_set(819234, :extras => 'owner_name,last_update,tags,views')

photo = photos.first
photo.tags.join(' ') # => "cave cold forrest"
photo.owner.username # => "jsmith"
photo.updated_at     # => 2012-04-20 23:29:17 +0200
photo.views_count    # => 24
```

On the list of available parameters you can read in the [Flickr API documentation](http://www.flickr.com/services/api/),
under the corresponding API method name (in the above case the method name would be `flickr.photosets.getPhotos`).

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

If you already have an existing photo (providing it holds its ID), you can also get info like this:

```ruby
photo.description # => nil
photo.get_info
photo.description # => "In this photo Peter said something really funny..."
```

You'll also probably want to display these photos in your app. There are
some neat methods available for you to help you out with this.

```ruby
photo = Flickrie.get_photo_sizes(8232348)
# or "photo.get_sizes" on an existing photo

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
For photos (and videos) have a look at the `Flickrie::Media` module,
because it's included into `Flickrie::Photo` and `Flickrie::Video`, and most
of the attributes are there.

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
access_token.user_params # => {:fullname => "John Smith", :user_nsid => "67131352@N03", :username => "jsmith"}
```

When getting the authorization url, you can also call
```ruby
request_token.get_authorization_url(:permissions => "read")
```
to ask only for "read" permissions from the user. Available permissions
are "read", "write" and "delete".

If you want to make authentication in your web application, check out my
[flickr_auth](https://github.com/janko-m/flickr_auth) gem.
Or, if you want to do it manually, check out
[this wiki](https://github.com/janko-m/flickrie/wiki/Authentication-in-web-applications)
for instructions.

## Photo upload

```ruby
photo_id = Flickrie.upload("/path/to/photo.jpg", :title => "A cow")
photo = Flickrie.get_photo_info(photo_id)
photo.title # => "A cow"
```

For the list of parameters you can pass in when uploading a photo, see
[this page](http://www.flickr.com/services/api/upload.api.html).

Note that photo uploads require authentication with "write" permissions.

See [this wiki](https://github.com/janko-m/flickrie/wiki/Asynchronous-photo-upload) for an example
of an asynchronous photo upload.

## A few words

Now, I covered only a few out of many Flickr's API methods using this approach,
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
with getting started with ruby. And he also helped me with the
basis of this gem.

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

# photos.upload
"flickr.photos.upload.checkTickets"     -> Flickrie.check_upload_tickets

# photosets
"flickr.photosets.getInfo"              -> Flickrie.get_set_info
"flickr.photosets.getList"              -> Flickrie.sets_from_user
"flickr.photosets.getPhotos"            -> Flickrie.photos_from_set

# test
"flickr.test.login"                     -> Flickrie.test_login
```

## Changelog

You can see the changelog [here](https://github.com/janko-m/flickrie/blob/master/CHANGELOG.md).

## Social

You can follow me on Twitter, I'm **@m_janko**.

## License

[MIT](https://github.com/janko-m/flickrie/blob/master/LICENSE)
