require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Nationbuilder < OmniAuth::Strategies::OAuth2
      # Give your strategy a name.
      option :name, "nationbuilder"

	  # We need the nation slug from the user and will use that as the unique id
	  # for this strategy
	  option :nation_slug, nil
      option :slug_param, 'nationslug'
      
	  def authorize_params
		super.tap do |params|
          params[:site] = 'https://' . options.nation_slug . 'nationbuilder.com'
        end	  	
	  end  

	  # Build a form to get the nations slug if one has not been supplied
	  def get_slug
        f = OmniAuth::Form.new(:title => 'NationBuilder Authentication')
        f.label_field("Your Nation's Slug", options.slug_param)
        f.input_field('url', options.slug_param)
		f.button "Connect to your Nation"
        f.to_response
      end
      
      # Returns the slug, nil if one has not been specified
      def slug
        s = options.nation_slug || request.params[options.slug_param.to_s]
        s = nil if s == ''
        session["omniauth.nationbuilder.slug"] = s if s
        s
      end
      
      # Override the normal OAuth request_phase to get a slug from the user if
      # one hasn't been supplied
      def request_phase
        slug ? super : get_slug
      end

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid { session["omniauth.nationbuilder.slug"] }

      def raw_info
        @raw_info ||= access_token.get('/me').parsed
      end
    end
  end
end