# Imutation

This app is a small proof of concept service for serving images and mutating images based on params sent from the client. How might be this helpful? Or rather - what is a good use case for this service?

The new [picture](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/picture) element and srcset attribute help deal with adaptive images.  They allow multiple image urls to be specified on a single img or picutre tag.
```
<picture>
  <source media="(max-width: 799px)" srcset="http://localhost:3000/i?url=https://i.imgur.com/2u4Ob9i.jpeg&resize_to_fill=480,480" />
  <source media="(min-width: 800px)" srcset="http://localhost:3000/i?url=https://i.imgur.com/2u4Ob9i.jpeg&resize_to_fill=800,800" />
  <img src="http://localhost:3000/i?url=https://i.imgur.com/2u4Ob9i.jpeg" alt="Squeeeee" />
</picture>
```

It allows you to have a caching layer to your image assets without having to rely on external sources. You probably have a use case in mind. Give it a shot!

# Setup
- clone the repo

# Local ruby
- Setup ruby (written on 3.2.0)
- execute bin/setup
- rails s

# Docker
- docker build

Try some test images:
- http://localhost:3000/i?url=https://i.imgur.com/2u4Ob9i.jpeg
- http://localhost:3000/i?url=https://i.imgur.com/2u4Ob9i.jpeg&crop=50,250,500,520

# Available mutations
- resize_to_limit
- resize_to_fit
- resize_to_fill
- crop
- rotate
- quality

Also available at http://localhost:3000/i/help

# Dashboard
There is currently only a root route for web view. The dashboard is serving up a table with the logs of the last image requests. In the future this will probably expand
to be more intricate, but for now it gets you started.

# TODO
* Make this docker compatible
  * Store DB in persistent volume unless you want it to be ephemiral

## Future Tasks
* Self scheduling cleanup jobs - on set schedule or triggered by volume usage
* When serving an original or variant, touch the DB row so we can clean up LRU
* Support FS store instead of DB. Based on ENV variable or config.
* Authentication for dashboard
* Tokenization or authorization scheme for requests
* Separate original images from variants.
  * has_many relationship to variants, dependent destroy
  * prefer cleaning up variants to originals

## FAQ
* Why does it use [insert tech here]? Because I wanted to utilizing specific technologies and this was a good use case. It's a proof of concept.

* Will you add [feature request]? Probably not, but you can ask. In the meantime why don't you impliment it to fit your use case. Maybe you can
contribute back a pull request when it's fleshed out.
