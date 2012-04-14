# Flickr

This gem is a nice wrapper for the Flickr API via an intuitive interface.

## Examples of usage

You first need to set the API key.

```ruby
require 'flickr'
Flickr.api_key = "some_api_key"
```

Then you can search for stuff.

```ruby
Flickr.find_photo_by_id(942827) # => #<Photo: size="Medium 500", url="http://farm1.staticflickr.com/5/4896740_fd69224bd0.jpg", width="481", height="426", ...>
Flickr.find_user_by_id("67313352@N04") # => #<User: username="jsmith", real_name="John Smith", photos_count=152, ...>
Flickr.photos_from_set(819234) # => [#<Photo: size="Medium 500", ...>, #<Photo: size="Square 150", ...>, ...]
```
