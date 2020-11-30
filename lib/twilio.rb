class Twiml
  @@BLOCKS = {
    :call => lambda { |r, h|
      if h['From'] != CONF['owner']
        r.gather(action: '/menu', numDigits: 1, timeout: 10) { |g|
          g.say(message: CONF['callcenter']['welcome'])
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
      
    },
    :admin => lambda { |r,h|

    }
  }
  def initialize b, h={}
    @b = b
    @h = h
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
  def self.blocks
    @@BLOCKS
  end
end
