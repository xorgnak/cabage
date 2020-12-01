module TWILIO
  def self.sendSms f, t, m
    th = {
      from: f,
      to: t,
      body: m
    }
    @x = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
    @x.messages.create(th) 
  end
  def self.set_job u
    if Redis::HashKey.new("callcenter:pins")[u] == nil
      p = [rand(9), rand(9), rand(9), rand(9)]
      Redis::HashKey.new("callcenter:pins")[p.join('')] = u
      Redis::HashKey.new("callcenter:jobs")[u] = p.join('')
    end
  end
  def self.get_sms h={}
    ow = Redis::HashKey.new("callcenter:active:on")[h['To']]
    u = Profile.new(ow)
    TWILIO.set_job h['From']
    if h['From'] != ow
      j = Redis::HashKey.new("callcenter:jobs")[h['From']]
      TWILIO.sendSms(h['To'], ow, "[#{j}] #{h['From']} #{h['Body']}")
    else
      w = h['Body'].split(' ')
      u = w.shift
      TWILIO.sendSms(h['To'], Redis::HashKey.new("callcenter:pins")[u] , "#{w.join(' ')}") 
    end
  end
  def self.get_call h={}
    ow = Redis::HashKey.new("callcenter:active:on")[h['To']]
    u = Profile.new(ow)
    TWILIO.set_job h['From']
    if h['Digits']
      @o = Twilio::TwiML::VoiceResponse.new do |resp|
        resp.play( digits: '1w1' )
        resp.dial( number: Redis::HashKey.new("callcenter:pins")[h['Digits']] )
        resp.redirect('/call', method: 'GET')
      end.to_s
    else
      if h['From'] != ow
        j = Redis::HashKey.new("callcenter:jobs")[h['From']]
        TWILIO.sendSms(h['To'], ow, "[#{j}] #{h['From']} CALL")
      end 
      @o = Twilio::TwiML::VoiceResponse.new do |resp|
        resp.gather(action: '/call',
                    input: 'dtmf',
                    method: 'GET') { |g|
          g.say(voice: 'male', message: "hello, " + u.attr['pitch'] + " in " + u.attr['city'] + ", you will recieve a call about your task shortly.  thanks." )
          g.hangup
        }
      end.to_s
    end
    return @o
  end
end
