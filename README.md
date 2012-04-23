# Flickrie

## About

This gem is a nice wrapper for the Flickr API with an intuitive interface.

The reason why I did this gem is because the other ones either weren't
well maintained, or they were too literal in the sense that the response from
the API call wasn't processed almost at all. It doesn't seem too bad
at first, but after a while you realize it's not pretty. So I wanted to
make it pretty :)

## Examples of usage

You first need to install the gem.

```
[sudo] gem install flickrie
```

Then in your app you require it and set the API key.

```ruby
require 'flickrie'
Flickrie.api_key = "<your_api_key>"
Flickrie.shared_secret = "<your_shared_secret>"
```

Then you can search for photos.

```ruby
photos = Flickrie.photos_from_set(819234) # => [#<Photo: id="8232348", ...>, #<Photo: id="8194318", ...>, ...]

photo = photos.first
photo.id          # => "8232348"
photo.url         # => "http://www.flickr.com/photos/67313352@N04/8232348"
photo.title       # => "Samantha and me"
photo.owner       # => #<User: nsid="67313352@N04", ...>
photo.owner.nsid  # => "67313352@N04"
```

Note that what Flickr refers to as "photoset" in its documentation, I
refer to as "set". This is because the word "photoset" would be wrong,
since sets can also hold videos.

You can also throw in some parameters to get more information about photos.  For example,

```ruby
photos = Flickrie.photos_from_set(819234, :extras => 'owner_name,last_update,tags,views')

photo = photos.first
photo.tags           # => "cave cold forrest"
photo.owner.username # => "jsmith"
photo.updated_at     # => 2012-04-20 23:29:17 +0200
photo.views_count    # => 24
```

On the list of available parameters you can read in the [Flickr API documentation](http://www.flickr.com/services/api/), under the corresponding API method name (in the above case it's `flickr.photosets.getPhotos`).

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

You can also get this info on an existing photo:

```ruby
photo.description # => nil
photo.get_info
photo.description # => "In this photo Peter said something really funny..."
```

If you want to display photos from flickr in your app, this is probably the most useful part:

```ruby
photo = Flickrie.get_photo_sizes(8232348)

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

If you want sizes to be available to photos you're fetching from a set, it's a bad idea to call `#get_sizes` on each photo, because that will make an HTTP request on each photo, which can be very slow. Instead, you should pass in these options:

```ruby
photos = Flickrie.photos_from_set(1242379, :extras => 'url_sq,url_q,url_t,url_s,url_n,url_m,url_z,url_c,url_l,url_o')
photo = photos.first
photo.medium!(640)
photo.source_url # => "http://farm8.staticflickr.com/7049/6946979188_25bb44852b_z.jpg"
```

These are just some of the cool things you can do. To see a full list of available methods, I encourage you to read the [wiki](https://github.com/janko-m/flickrie/wiki). I promise, I will document the methods properly in near future :)

## Authentication

```ruby
require 'flickrie'

Flickrie.api_key = "<your api key>"
Flickrie.shared_secret = "<your shared secret>"

url = Flickrie.get_authorization_url
puts "Visit this url to authorize: #{url}"
puts "Then enter the code that was displayed: "
code = gets.strip
Flickrie.authorize!(code)
puts "You're all done! Now go make some authenticated requests. Make me proud, son."
```

When calling `Flickrie.get_authorization_url`, you can also pass in the option `:permissions => "<perms>"`, where instead of `<perms>` you write either `read`, `write` or `delete`.

## A few words

Now, I covered only a few out of many Flickr's API methods using this approach, but I'll constantly update this gem with new API methods. For all of the methods I didn't cover, you can call them using `Flickrie.client`, like this:

```ruby
response = Flickrie.client.get("flickr.photos.getContext", :photo_id => 2842732)
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

Please, feel free to post any issues that you're having, I will try to
help you in any way I can.

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
- `flickr.photos.getInfo`
- `flickr.photos.getSizes`
- `flickr.photos.search`

### photos.licenses
- `flickr.photos.licenses.getInfo`

### photosets
- `flickr.photosets.getInfo`
- `flickr.photosets.getList`
- `flickr.photosets.getPhotos`

## License

[MIT](http://github.com/janko-m/flickrie/blob/master/LICENSE)
