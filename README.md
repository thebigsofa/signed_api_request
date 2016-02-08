[![Build Status](https://travis-ci.org/thebigsofa/signed_api_request.svg?branch=master)](https://travis-ci.org/thebigsofa/signed_api_request)

# Signed API request

Generate signed API requests needed when using Big Sofa embeddable widget player.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'signed_api_request'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install signed_api_request

## Usage

```ruby
SignedApiRequest.configure do |config|
  config.key_id = 'your_api_key_id'
  config.secret = 'your_api_secret'
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

