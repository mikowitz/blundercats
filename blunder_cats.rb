require 'sinatra/base'

class BlunderCats < Sinatra::Base
  enable :sessions

  configure do
    use Rack::Session::Cookie
    use OmniAuth::Builder do
      provider :twitter, ENV['BLUNDERCATS_CONSUMER_KEY'], ENV['BLUNDERCATS_CONSUMER_SECRET']
    end
  end

  helpers do
    def user
      @user ||= OpenStruct.new(session[:user])
    end
  end

  get '/' do
    %( <a href='/auth/twitter'>Sign in with Twitter</a> )
  end

  get '/auth/:name/callback' do
    session[:user] = request.env['omniauth.auth']['user_info']
    %( <p><img src="#{user.image}" />#{user.nickname} - #{user.name}</p> )
  end
end
