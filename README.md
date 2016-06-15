[![Gem Version](https://badge.fury.io/rb/omniauth-nationbuilder.svg)](https://badge.fury.io/rb/omniauth-nationbuilder)
[![Build Status](https://travis-ci.org/chrisjensen/omniauth-nationbuilder.svg?branch=master)](https://travis-ci.org/chrisjensen/omniauth-nationbuilder)

# Omniauth::Nationbuilder

Strategy to authenticate with Nationbuilder in OmniAuth.

## Installation

Add this line to your application's Gemfile:

    gem 'omniauth-nationbuilder'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-nationbuilder

## Usage

Here's an example for adding the middleware to a Rails app in config/initializers/omniauth.rb:

````ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :nationbuilder, ENV["NATIONBUILDER_CLIENT_ID"], ENV["NATIONBUILDER_CLIENT_SECRET"]
end
````

Because every nation has it's own slug, and this may be configured at run time if you are supporting authorisation of multiple nations, this is passed by a url parameter.

To authenticate your nation, use

	 /auth/nationbuilder?nation_slug=<YOUR NATIONS SLUG>


## Auth Hash

Here's an example of an authentication hash available in the callback by accessing request.env["omniauth.auth"]:

````ruby
	{
	  :provider => "nationbuilder",
	  :uid => "YOUR NATIONS SLUG",
	  :credentials => {
		:token => "f4d3b3c9528672fa15181dfd9e63a793f4e754186bbeaad7030b053e1398b84f",
		:expires => false 
	  },
	  :extra => {
		:token_type => "bearer",
		:created_at => 1465867529,
		:access_token => "f4d3b3c9528672fa15181dfd9e63a793f4e754186bbeaad7030b053e1398b84f",
		:refresh_token => nil,
		:expires_at => nil
	  }
	}
````

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
