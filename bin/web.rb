class App < Sinatra::Base
  before do
    log('app',"#{params} #{request.fullpath}")
    if request.fullpath != '/'
    if params[:id]                                                               
      @id = Profile.new(params[:id])                                                   
      @attr = @id.attr.all                                                             
      @stat = @id.stat.members(with_scores: true).to_h
      @js = JS.new(params[:id])
    end
    end 
  end
  
  configure do
    set :bind, '0.0.0.0'
    set :port, 8080
    set :views, 'views'
    set :public_dir, 'public'
  end
  helpers do

  end
  
  post('/') do
    log('post', "#{params}") 
    x = Handle::Post.new(params)
    t = []; 64.times { t << rand(16).to_s(16); }
    @tok = t.join('');
    if params[:id]
      @id = Profile.new(params[:id])
      @attr = @id.attr.all                                                            
      @stat = @id.stat.members(with_scores: true).to_h
      @js = JS.new(params[:id])
      @form = {}
      if params[:form]
      params[:form].split("&").each { |e|
        k = /data\[(.+)\]=/.match(e);
        v = e.gsub(/data\[(.+)\]=/, '')
        @form[k] = v
      }
      end
    end 
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
  get('/api/v1/:a') { a = params.delete(:a); @api.run(a, params) }
  get('/ads.txt') {} 
  get('/robots.txt') {}
  get('/webmanifest') { erb :webmanifest }
  get('/favicon.ico') {}
  get('/sms') { TWILIO.get_sms(params) }
  get('/call') { TWILIO.get_call(params) }
  [:profile, :shop, :auth, :make, :sign, :ui, :theatre, :tasker, :peer].each { |r|
    get("/#{r}") { erb r };
  }
  not_found do
    log "ERROR.not_found", "#{params} #{request.fullpath}"
  end
  error do
    log "ERROR", "#{env}"
  end
end
Process.detach(fork { App.run! })
