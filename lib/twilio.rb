class Twiml
  class User
    include Redis::Objects
    hash_key :attr
    sorted_set :stat
    def initialize i
      @id = i
    end
    def id; @ud; end
  end
  @@BLOCKS = {
    :call => lambda { |r, h|
      if h['From'] != CONF['owner']
        if users[h['From']] == nil
          p = [rand(9), rand(9), rand(9)]
          until pins[p.join('')] == nil
            p = []
            4.times { p << rand(9) }
          end
          pins[p.join('')] = h['From']
          users[h['From']] = p.join('')
          ux = User.new(h['From'])
          ux.attr['pin']
        end
        r.gather(action: '/menu', numDigits: 1, timeout: 10) { |g|
          g.say(message: CONF['callcenter']['welcome'] + ", press 1 if you need your task done immediately." )
        };
      else
        r.gather(action: '/admin') { |g|
          g.play(digits: '1w2w3')
        };
      end
    },
    :sms => lambda { |r, h|
      
    },
    :menu => lambda {|r,h|
      ux = User.new(h['From'])
      ux.attr['priority'] = h['Digits']
      r.gather(action: '/bye', numDigits: 1, timeout: 10) { |g|
                  g.say(message: CONF['callcenter']['welcome'] + "press 1 for virtual or consulting tasks or 2 for physical tasks." )
      }; 
    },
    :bye => lambda { |r, h|
      ux = User.new(h['From'])
      ux.attr['type'] = h['digits']
      bd = "[#{users[h['From']]}] #{h['From']} #{attr(h['From'], 'priority')} #{attr(h['From'], 'type')} #{h['Body']}"
      Twiml.new(:sms, { to: CONF['owner'], body: bd }).push
      r.say(message: "thank you.  You will recieve a call shortly.")
    },
    :admin => lambda { |r,h|
      
    },
    :call_status => lambda { |r,h|

    }
  }
  def initialize b, h={}
    @b = b
    @h = h
  end
  def users
    Redis::HashKey.new("callcenter")
  end
  def pins
    Redis::HashKey.new("pins")
  end
  def push
    Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']).messages.create(@h)
  end
  def sms
    Twilio::TwiML::MessagingResponse.new do |resp|
      @@BLOCKS[@b].call(resp, @h)
    end.to_s
  end
  def call
    Twilio::TwiML::VoiceResponse.new do |resp|
      @@BLOCKS[@b].call(resp, @h)
    end.to_s
  end
  def menu
    call
  end
  def bye
    call
  end
  def admin
    call
  end
  def call_status

  end
  def self.blocks
    @@BLOCKS
  end
end
