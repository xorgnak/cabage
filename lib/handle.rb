module Handle
  class Post
    def initialize h
      log('Handle::Post', "#{h}")
      @h = h
      @mode = :index
      @oh = { time: Time.now.to_f }
      u = Profile.new(@h[:id])
      if @h[:product]
        x = Product.new()
        xx = Product.new(id: x); 
        @h.each_pair {|k,v| if k != :id; xx.attr[k] = JSON.generate(v); end }
        u.products << x
      elsif @h[:do]  == 'index' && !u.attr.has_key?('pin')
        @h[:go] = '/make'
      elsif @h[:do]  == 'profile' && u.attr.has_key?('pin')
        if u.attr['pin'] != @h[:pin]
          @h[:go] = '/404'
        else
          @h.each_pair {|k,v| if k != :id; u.attr[k] = v; end }
          Redis::HashKey.new("callcenter:active:on")[@h[:worknumber]] = "+1" + @h[:id] 
        end
      end
      @r, @o = [], []
      @go = false
      if @h[:go]
        packRoute
        @go = true
      end
      mqttSend("cabgo/#{h[:id]}/post", "#{JSON.generate(@h)}") 
      packErb
    end
    def go?
      @go
    end
    def route
      @r.join('')
    end
    def result
      @o.join('')
    end
    def packRoute
      @r << @h[:go]
      @r << '?'
      if @h.has_key? :params
        @h['params'].each_pair {|k,v| @r << %[#{k}=#{@h[v.to_sym]}&] }
      end
      @r << %[id=#{@h[:id]}]
      return @r.join('')
    end
    def packErb
#      @o << "<h1><code style='width: 100%; background-color: black; color: orange;'>#{@h}</code></h1>"
       @o << "<input type='hidden' name='token' value='<%= @tok %>'>"
      @o << "<input type='hidden' name='id' value='#{@h[:id]}'>"
      @o << "<%= erb :#{@h[:do]} %>"
    end
  end
  class Get     
    def initialize h
      mqttSend("cabgo/get", "#{JSON.generate(h)}")
    end
  end 
end

def butler
  Redis.new( host: "vango.me", db: 1 )
end
class Butler
  def initialize
    @onion = Redis.new.get('ONION')
    if File.exists? 'addressbook.json'
      @book = JSON.parse(File.read('addressbook.json'))
    else
      @book = {}
    end
  end
  def save!
    File.open("addressbook.json", 'w') {|f| f.write(JSON.generate(@book)) }
  end
  def peek!
    butler.monitor {|e| puts "#> #{e}" }
  end
  def my_id
    r = Redis.new
    b = r.get(@onion)
    if b == nil || b == ""
      a = []; 8.times { a << rand(16).to_s(16) }
      r.set(@onion, a.join(''))
      return a.join('')
    else
      return b
    end
  end
  def daemon ch, &b
    Process.detach( fork {
                      butler.subscribe(Base64.urlsafe_encode64(ch)) do |on|
                        on.message do |ch, msg|
                          j = JSON.parse(Base64.urlsafe_decode64(msg))
                          puts "[#{j['from']}] #{j['msg']}"
                        end
                      end
                    })
  end
  def client
    puts "#### BUTLER ####"
    puts RQRCode::QRCode.new(my_id, size: 1, level: :l ).as_ansi
    puts "you: #{my_id}"
    print "to: "
    t = gets.chomp
      daemon(t)
    puts "press Ctrl-C to exit"
    loop do
      print "> "
      m = gets.chomp
      h = { from: my_id, msg: m }
      butler.publish(Base64.urlsafe_encode64(t), Base64.urlsafe_encode64(JSON.generate(h)))
    end
  end
end
def alleyway
  Butler.new.client
  Signal.trap('INT') { exit 0 }
end
