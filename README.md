# UriSigner

  - [![Version](https://badge.fury.io/rb/uri_signer.png)](https://rubygems.org/gems/uri_signer)
  - [![Climate](https://codeclimate.com/github/kissmetrics/uri_signer.png)](https://codeclimate.com/github/kissmetrics/uri_signer)
  - [![Build](http://img.shields.io/travis-ci/kissmetrics/uri_signer.png)](https://travis-ci.org/kissmetrics/uri_signer)
  - [![Dependencies](https://gemnasium.com/kissmetrics/uri_signer.png)](https://gemnasium.com/kissmetrics/uri_signer)
  - [![Coverage](http://img.shields.io/coveralls/kissmetrics/uri_signer.png)](https://coveralls.io/r/kissmetrics/uri_signer)
  - [![License](http://img.shields.io/license/MIT.png?color=green)](http://opensource.org/licenses/MIT)

The KISSmetrics API provides an authentication realm of a digital
signature of the request. This gem helps to put the pieces together and
construct the URL with the signature.

This is used within the core KISSmetrics Ruby API Wrapper to help
abstract the building of the requests.

Using this without a wrapper will require you to manually provide your
*client_secret*.

## Installation

Add this line to your application's Gemfile:

    gem 'uri_signer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install uri_signer

## Usage

At any point, you can use the `reload_yard` command to view the
documentation of the provided code. The basic usage is:

```ruby
http_method = 'get'
uri = "https://api.example.com/v1/endpoint.json?page=2&per_page=12&order=name:desc&select=id,name"
secret = "my_secret"

signer = UriSigner::Signer.new(http_method, uri, secret)
=> #<UriSigner::Signer:0x007fd84ebf5490 @http_method="get", @uri="https://api.example.com/v1/endpoint.json?page=2&per_page=12&order=name:desc&select=id,name", @secret="my_secret">

signer.http_method
=> "GET"

signer.uri
=> "https://api.example.com/v1/endpoint.json?page=2&per_page=12&order=name:desc&select=id,name"

signer.signature
=> "Itt0xvD1ZAHHXP2ItX6PeXMfjOovr8MVgbpoXpq3158%3D"

signer.uri_with_signature
=> "https://api.example.com/v1/endpoint.json?page=2&per_page=12&order=name:desc&select=id,name&_signature=Itt0xvD1ZAHHXP2ItX6PeXMfjOovr8MVgbpoXpq3158%3D"

signer.valid?('Itt0xvD1ZAHHXP2ItX6PeXMfjOovr8MVgbpoXpq3158%3D')
=> true

signer.valid?('invalid')
=> false
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
