# UriSigner

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

http_method = "get"
uri         = "https://api.example.com/core/people.json?page=5&per_page=25&order=name:desc&select=id,name"
secret      = "my_secret"

signer = UriSigner::UriSigner.new(http_method, uri, secret)

signer.http_method
# => "GET"

signer.uri
# => "https://api.example.com/core/people.json?page=5&per_page=25&order=name:desc&select=id,name"

signer.signature
# => "1AaJvChjz%2BZYJKxWsUQWNK1a%2BeGjpCs6uwQKwPw1%2FV8%3D"

signer.uri_with_signature
# => "https://api.example.com/core/people.json?_signature=6G4xiABih7FGvjwB1JsYXoeETtBCOdshIu93X1hltzk%3D"

signer.valid?("1AaJvChjz%2BZYJKxWsUQWNK1a%2BeGjpCs6uwQKwPw1%2FV8%3D")
# => true

signer.valid?('1234')
# => false
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
