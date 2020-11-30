class Twiml
  @@JOBS = {}
  @@PINS = {}
  @@BLOCKS = {
    :call => lambda { |r, h|
      if h['From'] != CONF['owner']
        if !@@JOBS.has_key? h['From']
          p = [rand(9), rand(9), rand(9), rand(9)]
          @@PINS[p.join('')] = h['From']
          @@JOBS[h['From']] = p.join('')
        end
        r.gather(action: '/bye', numDigits: 1, timeout: 10) { |g|
          g.say(message: CONF['callcenter']['welcome'] + ", on a scale from 1 being right now and 9 being later, how immediately does your task need to be done?" )
        };
      else
        r.gather(action: '/admin') { |g|
          g.play(digits: '1w2w3')
        };
      end
    },
    :sms => lambda { |r, h|
      
    },
    :bye => lambda { |r, h|
      bd = "[#{@@JOBS[h['From']]}] #{h['From']} #{h['Digits']}"
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
