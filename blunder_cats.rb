require 'sinatra/base'

class BlunderCats < Sinatra::Base
  enable :sessions

  configure do
    use Rack::Session::Cookie
    use OmniAuth::Builder do
      provider :twitter, ENV['BLUNDERCATS_CONSUMER_KEY'], ENV['BLUNDERCATS_CONSUMER_SECRET']
    end

    DataMapper.setup(:default, ENV['DATABASE_URL'])
    load 'list.rb'
  end

  helpers do
    def user
      @user ||= OpenStruct.new(session[:user])
    end

    def logged_in?
      # TODO: this is pretty weak
      user.nickname
    end

    def require_list_permissions
      go_away unless user.nickname == params[:user] || List.get(params[:user], params[:list]).member?(user.nickname)
    end

    def go_away
      redirect '/'
      halt
    end
  end

  get '/' do
    if logged_in?
      %( <p>sorry, this isn't fully baked yet.  a work in progress, etc...</p><p>fwiw, your session user is #{session[:user].inspect}</p> )
    else
      %( <a href='/auth/twitter'>Sign in with Twitter</a> )
    end
  end

  get '/auth/:name/callback' do
    session[:user] = request.env['omniauth.auth']['user_info']
    %( <p><img src="#{user.image}" />#{user.nickname} - #{user.name}</p> )
  end

  get '/:user/lists/:list/?' do
    require_list_permissions

    @list = List.get(params[:user], params[:list])
    haml :list
  end

  get '/:user/lists/:list/random/:kind' do
    image_url = Image.random_url(params[:list], params[:user], params[:kind].split('.')[0])
    if params[:kind] =~ /\.txt$/
      image_url
    else
      redirect image_url
    end
  end

  post '/:user/lists/:list/images' do
    require_list_permissions
    Image.create(
      :list_slug => params[:list],
      :list_creator => params[:user],
      :added_by => user.nickname,
      :kind  => params[:kind],
      :source_url => params[:url]
    )

    redirect "#{params[:user]}/lists/#{params[:list]}"
  end

  get '/:user/lists/:list/load' do
    require_list_permissions
    List.sync(user.nickname, params[:list])
    redirect "#{user.nickname}/lists/#{params[:list]}"
  end
end
