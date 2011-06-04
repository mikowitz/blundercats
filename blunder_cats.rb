require 'sinatra/base'

class BlunderCats < Sinatra::Base
  enable :sessions

  configure do
    use Rack::Session::Cookie
    use OmniAuth::Builder do
      provider :twitter, ENV['BLUNDERCATS_CONSUMER_KEY'], ENV['BLUNDERCATS_CONSUMER_SECRET']
    end

    DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3://my.db')
    load 'list.rb'
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

  get '/refresh/:list' do
    return unless user.nickname

    List.sync(user.nickname, params[:list]).to_json
  end
end
