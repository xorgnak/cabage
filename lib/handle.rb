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
      elsif @h[:do]  == 'pin' && !u.attr.has_key?('pin')
        @h[:go] = '/make'
      elsif @h[:do]  == 'profile' && u.attr.has_key?('pin')
        if u.attr['pin'] != @h[:pin]
          @h[:go] = '/auth'
        end
      else
        @h.each_pair {|k,v| if k != :id; u.attr[k] = v; end }
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
