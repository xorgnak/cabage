module Handle
  class Post
    def initialize h
      @h = h
      @mode = :index
      @oh = { time: Time.now.to_f }
      @o = []
      @go = false
      if h[:go]
        packRoute
        @go = true
      end
      packErb
      mqttSend("cabgo/#{h[:id]}/post", "#{h}")
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
      @r << '/'
      @r << @h[:go]
    end
    def packErb
      @o << "<code>#{@h}</code>"
      @o << "<input type='hidden' name='id' value='#{@h[:id]}'>"
      @o << "<%= erb :#{@h[:do] || 'index'} %>"
      @o << "<%= erb :footer %>"
    end
  end
  class Get                                                                       
    def initialize h
      mqttSend("cabgo/get", "#{JSON.generate(h)}")
    end
  end 
end
