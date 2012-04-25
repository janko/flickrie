# Flickrie

## About

This gem is a nice wrapper for the Flickr API with an intuitive interface.

The reason why I did this gem is because the other ones either weren't
well maintained, or they were too literal in the sense that the responses from
the API calls weren't processed almost at all. It doesn't seem too bad
at first, but it would be great that, for example, if you're reading a time attribute,
such as `last_update`, you actually **get** the instance of `Time`, and
not a string representing that time (often in a timestamp (integer) format).
That's what wrappers should be for.

The method names here aren't called the same as Flickr's API methods, but they follow a pattern which
shouldn't be too difficult to learn. Also, some attribute names that you
get from the response are changed. So, for example, the `last_update`
attribute is called `updated_at`, and the `candownload` attribute is
called `can_download?`. After all, this is a **ruby** wrapper, so it
should be written in Ruby/Rails fashion :)

## Examples of usage

You first need to install the gem.

```
[sudo] gem install flickrie
```

Then in your app you set the API key and secret (which you can apply
for [here](http://www.flickr.com/services/apps/create/apply)).

```ruby
require 'flickrie'
Flickrie.api_key = "your api key"
Flickrie.shared_secret = "your shared secret"
```

Then you can search for stuff.

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

Note that, what Flickr refers to as "photoset" in its documentation, I
refer to as "set". This is because the word "photoset" is actually
incorrect, since sets can also hold videos.

You can also throw in some parameters to `.photos_from_set` to get more information about photos. For example,

```ruby
photos = Flickrie.photos_from_set(819234, :extras => 'owner_name,last_update,tags,views')

photo = photos.first
photo.tags           # => "cave cold forrest"
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

If you already have an existing photo, you can also get info like this:

```ruby
photo.description # => nil
photo.get_info
photo.description # => "In this photo Peter said something really funny..."
```

You'll also probably want to display these photos in your app.

```ruby
photo = Flickrie.get_photo_sizes(8232348)
# or "photo.get_sizes" on an existing photo

photo.medium!(800)
photo.size       # => "Medium 800"
photo.source_url # => "http://farm8.staticflickr.com/7049/6946979188_25bb44852b_c.jpg"
photo.width      # => 600
photo.height     # => 800

photo.small!(320)
photo.size       # => "Small 320"
photo.source_url # => "http://farm8.staticflickr.com/7049/6946979188_25bb44852b_n.jpg"
photo.width      # => 240
photo.width      # => 320
```

You can see the full list of available methods and attributes in the
[documentation](http://rubydoc.info/gems/flickrie/0.1.2/frames).

## Authentication

```ruby
require 'flickrie'

Flickrie.api_key = "your api key"
Flickrie.shared_secret = "your shared secret"

request_token = Flickrie::OAuth.get_request_token
url = request_token.get_authorization_url
puts "Visit this url to authenticate: #{url}"

print "If you agreed, the code was displayed afterwards. Enter it: "
code = gets.strip
access_token = Flickrie::OAuth.get_access_token(code)
Flickrie.access_token = access_token.token
Flickrie.access_secret = access_token.secret
puts "You successfully authenticated!"
```

When getting the authorization url, you can also call
```ruby
request_token.get_authorization_url(:permissions => "read")
```
to ask only for "read" permissions from the user. Available permissions
are "read", "write" and "delete".

## A few words

Now, I covered only a few out of many Flickr's API methods using this approach, but I'll constantly update this gem with new API methods. For all of the methods I didn't cover, you can call them using `Flickrie.client`, like this:

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
```

It's not nearly as pretty, but at least you can get to the data.

## Issues

Please, feel free to post any issues that you're having, I will be happy
to help. I will also be happy if you let me know about any bugs.

## Cedits

Special thanks to @**mislav**, my brother, he helped me really a lot
with getting started with ruby. And he also helped me with the
basis of this gem.

## Currently covered API methods

### people
- `flickr.people.findByEmail`
- `flickr.people.findByUsername`
- `flickr.people.getInfo`
- `flickr.people.getPublicPhotos`

### photos
- `flickr.photos.addTags`
- `flickr.photos.delete`
- `flickr.photos.getInfo`
- `flickr.photos.getSizes`
- `flickr.photos.removeTag`
- `flickr.photos.search`

### photos.licenses
- `flickr.photos.licenses.getInfo`

### photosets
- `flickr.photosets.getInfo`
- `flickr.photosets.getList`
- `flickr.photosets.getPhotos`

## Changelog

I will post the changelog here from now on. I apologize in advance for
some buggy releases, I know I've been doing so lately. My excuse is that
this is my first gem, and I just have to get a hang of it. If a release
is buggy, please be sure to check if there is a newer version available,
because that may be the fix. The last stable version should be 0.2.1.

## License

[MIT](http://github.com/janko-m/flickrie/blob/master/LICENSE)
