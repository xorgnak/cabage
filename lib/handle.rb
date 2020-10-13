module Handle
  class Post
    def initialize h
      mqttSend("cabgo/#{h[:id]}/post", "#{h}")
      log('Handle::Post', "#{h}")
      @h = h
      @mode = :index
      @oh = { time: Time.now.to_f }
      u = Profile.new(@h.delete(:id))
      @h.each_pair {|k,v| u.attr[k] = v}
      @r, @o = [], []
      @go = false
      if h[:go]
        packRoute
        @go = true
      end
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
        @h[:params].each_pair {|k,v| @r << %[#{k}=#{@h[v.to_sym]}&] }
      end
      @r << %[id=#{@h[:id]}]
      return @r.join('')
    end
    def packErb
      @o << "<code style='width: 100%; background-color: black; color: orange;'>#{@h}</code>"
      @o << "<input type='hidden' name='id' value='#{@h[:id]}'>"
      @o << "<%= erb :#{@h[:do] || 'index'} %>"
#      @o << "<%= erb :footer %>"
    end
  end
  class Get                                                                       
    def initialize h
      mqttSend("cabgo/get", "#{JSON.generate(h)}")
    end
  end 
end
