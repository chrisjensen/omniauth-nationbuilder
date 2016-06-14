require 'spec_helper'
require 'omniauth-nationbuilder'

describe OmniAuth::Strategies::Nationbuilder, :type => :strategy do
  def app
    strategy = OmniAuth::Strategies::Nationbuilder

    Rack::Builder.new {
      use Rack::Session::Cookie, :secret => 'suppress no secret warning'
      run lambda {|env| [404, {'Content-Type' => 'text/plain'}, [nil || env.key?('omniauth.auth').to_s]] }
    }.to_app
  end

  subject do
    OmniAuth::Strategies::Nationbuilder.new(app, 'appid', 'secret', {})
  end
  
  before do
    OmniAuth.config.failure_raise_out_environments = ['development','test','']
  end

  describe '/auth/nationbuilder' do
    context 'with nation_slug unset' do
		before do
		  request = { Rack::MockRequest.new(subject) }
		  request.get '/auth/nationbuilder'
		end

		it 'should respond with OK' do
		  expect(last_response).to be_ok
		end

		it 'should respond with HTML' do
		  expect(last_response.content_type).to eq('text/html')
		end

		it 'should prompt for nation slug' do
		  expect(last_response.body).to match %r{<input[^>]*nation_slug}
		end
	end
	
	context 'with nation_slug in get param' do
	  let(:slug) { 'mynation' }
	  let(:redirect_url) { 'https://' + slug + '.nationbuilder.com' }
    
      it 'should redirect to the NationBuilder oauth url' do
        get '/auth/nationbuilder?nation_slug=' + slug
        expect(last_response).to be_redirect
        expect(last_response.headers['Location']).to match(%r{^#{redirect_url}.*})
      end
	end
  end
  
	describe '/auth/nationbuilder/callback' do
		let(:client) do
		  OAuth2::Client.new('abc', 'def') do |builder|
			builder.request :url_encoded
		  end
		end
	
		let(:nb_response) do
		  {
			"access_token" => "token-string",
			"token_type" => "bearer",
			"created_at" => 1465867529
		  }		
		end
	
		let(:access_token) do
		  OAuth2::AccessToken.from_hash(client, nb_response )
		end

		before { allow(subject).to receive(:access_token).and_return(access_token) }
  
	  it "should provide nationbuilder auth hash in extra" do
		expect(subject.auth_hash.extra).to include(nb_response)
	  end
	end
    
    describe 'end to end' do
		let(:nb_response) do
		  {
		    "access_token" => "token-string",
			"token_type" => "bearer",
			"created_at" => 1465867529
		  }		
		end

	  let(:nation_slug) { 'georgesnation' }
	  
	  it "should save slug and put it in uid" do
		stub_request(:post, "https://georgesnation.nationbuilder.com/oauth/token").
         to_return(:status => 200, :body => nb_response.to_json,
          :headers => { "Content-Type" => "application/json; charset=utf-8" } )
         
	    # First get is necessary as nation slug is saved on session by the get
        get '/auth/nationbuilder?nation_slug=' + nation_slug

        session_state = CGI::parse(last_response.headers['Location'])['state'][0]

		get '/auth/nationbuilder/callback?code=valid_code&state=' + session_state

	    expect(subject.auth_hash).to include("uid" => nation_slug)
	  end
    end	
end