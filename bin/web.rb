class App < Sinatra::Base
  helpers do

  end
  
  configure do
    set :bind, '0.0.0.0'
    set :port, 8080
    set :views, 'views'
    set :public_dir, 'public'
  end
  post('/') do
    log('post', "#{params}") 
    x = Handle::Post.new(params)
    if x.go?
      redirect x.route
    else
      erb x.result
    end
  end
  get('/') do
    Handle::Get.new(params)
    erb :index
  end
  get('/favicon.ico') do

  end
  get('/:app') do
    log('app', "#{params}")
    if params['id']
    @id = Profile.new(params['id'])
    @attr = @id.attr.all
    @stat = @id.stat.members(with_scores: true).to_h
    end
    erb params[:app].to_sym
  end
end
Process.detach(fork { App.run! })
