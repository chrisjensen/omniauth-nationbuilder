require 'spec_helper'
require 'omniauth-nationbuilder'

describe OmniAuth::Strategies::Nationbuilder, :type => :strategy do
  def app
    strategy = OmniAuth::Strategies::Nationbuilder

    Rack::Builder.new {
      use Rack::Session::Cookie, :secret => 'suppress no secret warning'
      use strategy
      run lambda {|env| [404, {'Content-Type' => 'text/plain'}, [nil || env.key?('omniauth.auth').to_s]] }
    }.to_app
  end

  subject do
    OmniAuth::Strategies::Nationbuilder.new(app, 'appid', 'secret', @options || {})
  end
  
  before do
    OmniAuth.config.failure_raise_out_environments = ['development','test','']
  end

  describe '/auth/nationbuilder' do
    context 'with nation_slug unset' do
		before do
		  get '/auth/nationbuilder'
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
  
  describe 'callback_url' do
	  let(:nation_slug) { 'nationofkinggeorge' }

	before do
		allow(subject).to receive(:request) { double('Rack::Test::Request', {:params => {'nation_slug' => nation_slug }, :query_string => 'nation_slug=' + nation_slug, :env => { }}) }

		allow(subject).to receive(:full_host) { 'example.org' }
		allow(subject).to receive(:script_name) { '' }
	end

	it "should not include query string" do
	  expect(subject.callback_url).to eq('example.org/auth/nationbuilder/callback')
	end
  end

  ### NOTE ###
  # This section involves heavy stubbing of Omniauth and OAuth methods to verify
  # a small amount of code.
  # There is probably a better way to test this, but would require better knowledge of
  # rack middleware than I can bring
  describe 'session' do
	  before do
		OmniAuth.config.test_mode = true
	  end

	  after do
		OmniAuth.config.test_mode = false
	  end
  
	  let(:rack_cookies) do
		{}
	  end
	  
	  let(:nation_slug) { 'nationofkinggeorge' }

	  before do
		allow(subject).to receive(:request) { double('Rack::Test::Request', {:params => {'nation_slug' => nation_slug }, :query_string => 'query_string', :env => { 'rack.session' => rack_cookies }}) }

		allow(subject).to receive(:full_host) { 'example.org' }
		allow(subject).to receive(:script_name) { 'test' }
		allow(subject).to receive(:build_access_token) { {} }
		allow(subject).to receive(:env) { {} }
		allow(subject).to receive(:call_app!) { {} }
	
		allow(subject).to receive(:session) { rack_cookies }
	  end
  
	  describe 'request_phase' do

		  it 'should save the slug on the session' do
			subject.request_phase
			expect(subject.session['omniauth.nationbuilder.slug']).to eq(nation_slug)
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

			before do
			  allow(subject).to receive(:access_token).and_return(access_token)
			  subject.options.provider_ignores_state = true;
			end
  
		  it "should provide nationbuilder auth hash in extra" do
			expect(subject.auth_hash.extra).to include(nb_response)
		  end

		  it "should set uid from session" do
			subject.session['omniauth.nationbuilder.slug'] = nation_slug
			subject.callback_phase
			expect(subject.auth_hash).to include("uid" => nation_slug)
		  end
		end
	end
end