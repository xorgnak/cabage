def sendSms t, m
  th = {
    to: t,
    body: m
  }
  t = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
  t.messages.create(th) 
end
def user_job u
  if Redis::HashKey.new("callcenter:pins")[u] == nil
    p = [rand(9), rand(9), rand(9), rand(9)]
    Redis::HashKey.new("callcenter:pins")[p.join('')] = u
    Redis::HashKey.new("callcenter:jobs")[u] = p.join('')
  end  
end
class Twiml

  @@BLOCKS = {
    :call => lambda { |r, h|
      user_job h['From']
      r.gather(action: '/admin', timeout: 10) { |g|
        g.say(message: CONF['callcenter']['welcome'] + ", You will recieve a call about your task shortly" )
      }
      if h['From'] != CONF['owner']
        j = Redis::HashKey.new("callcenter:jobs")[h['From']]
        sendSms(CONF['owner'], "[#{j}] #{h['From']}")
      end
    },
    :sms => lambda { |r, h|
      user_job h['From']
      if h['From'] != CONF['owner']
        j = Redis::HashKey.new("callcenter:jobs")[h['From']]
        sendSms(CONF['owner'], "[#{j}] #{h['From']} #{h['Body']}")
        r.message(body: "You will recieve a call about your task shortly.")
      end 
    },
    :admin => lambda { |r,h|
      r.gather(action: '/admin') {|g| g.play(digits: '1p2p3') }
    },
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
