class Twiml
  @@JOBS = {}
  @@PINS = {}
  @@BLOCKS = {
    :call => lambda { |r, h|
      if !@@JOBS.has_key? h['From']
        p = [rand(9), rand(9), rand(9), rand(9)]
        @@PINS[p.join('')] = h['From']
        @@JOBS[h['From']] = p.join('')
      end
      r.gather(action: '/admin', timeout: 10) { |g|
        g.say(message: CONF['callcenter']['welcome'] + ", You will recieve a call about your task shortly" )
      }
      if h['From'] != CONF['owner']
      th = {
        to: CONF['owner'],
        body: "[#{@@JOBS[h['From']]}] #{h['From']}"
      }
      t = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
      t.messages.create(th)
      end
    },
    :sms => lambda { |r, h|
      
    },
    :admin => lambda { |r,h|
      r.gather(action: '/admin') {|g| g.play(digits: '1p2p3') }
    },
    :call_status => lambda { |r,h|

    }
  }
  def initialize b, h={}
    @b = b
    @h = h
    if b == :sms
      Twilio::TwiML::MessagingResponse.new do |resp|
        @@BLOCKS[@b].call(resp, @h)
      end.to_s  
    else
      Twilio::TwiML::VoiceResponse.new do |resp|
        @@BLOCKS[@b].call(resp, @h)
      end.to_s 
    end
  end
  def self.blocks
    @@BLOCKS
  end
end
