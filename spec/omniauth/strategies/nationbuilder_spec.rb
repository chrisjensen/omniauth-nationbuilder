require 'spec_helper'
require 'omniauth-nationbuilder'

describe OmniAuth::Strategies::Nationbuilder, :type => :strategy do
  def app
    strat = OmniAuth::Strategies::Nationbuilder
    Rack::Builder.new {
      use Rack::Session::Cookie
      use strat
      run lambda {|env| [404, {'Content-Type' => 'text/plain'}, [nil || env.key?('omniauth.auth').to_s]] }
    }.to_app
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
	
	context 'with nation_slug' do
	  let(:slug) { 'mynation' }
	  let(:redirect_url) { 'https://' + slug + '.nationbuilder.com' }
    
      it 'should redirect to the NationBuilder oauth url' do
        puts "slug: " + slug
        get '/auth/nationbuilder?nation_slug=' + slug
        last_response.should be_redirect
        last_response.headers['Location'].should =~ %r{^#{redirect_url}.*}
      end
	end
  end
end