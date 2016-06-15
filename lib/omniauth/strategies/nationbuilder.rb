require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Nationbuilder < OmniAuth::Strategies::OAuth2
      # Give your strategy a name.
      option :name, "nationbuilder"

	  # We need the nation slug from the user and will use that as the unique id
	  # for this strategy
	  option :nation_slug, nil
      option :slug_param, 'nation_slug'
      
	  # Build a form to get the nations slug if one has not been supplied
	  def get_slug
        f = OmniAuth::Form.new(:title => 'NationBuilder Authentication')
        f.label_field("Your Nation's Slug", options.slug_param)
        f.input_field('url', options.slug_param)
		f.button "Connect to your Nation"
        f.to_response
      end
      
      # Configure site before super initialises the OAuth2 Client
      def client
        options.client_options[:site] = 'https://' + options.client_options[:slug] + '.nationbuilder.com'
		log :debug, "Nation to authorise " + deep_symbolize(options.client_options).inspect
		super
      end
      
      # Returns the slug, nil if one has not been specified anywhere
      def slug
        s = options.nation_slug || request.params[options.slug_param.to_s]
        s = nil if s == ''
        s
      end
      
      # Override the normal OAuth request_phase to get a slug from the user if
      # one hasn't been supplied, and insert the slug into the site url
      def request_phase
        if slug
          # Store slug on the session
          session["omniauth.nationbuilder.slug"] = options.client_options[:slug] = slug
          super
        else
          get_slug
        end
      end
      
      def callback_phase
        options.client_options[:slug] = session.delete("omniauth.nationbuilder.slug")
        super
      end
            
      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid { options.client_options[:slug] }
      
      extra { access_token }
    end
  end
end