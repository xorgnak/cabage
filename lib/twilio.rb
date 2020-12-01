module TWILIO
  def self.sendSms t, m
    th = {
      from: '+15855144334',
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
    TWILIO.set_job h['From']
    #    if h['From'] != CONF['owner']
    j = Redis::HashKey.new("callcenter:jobs")[h['From']]
    TWILIO.sendSms(CONF['owner'], "[#{j}] #{h['From']} #{h['Body']}")
    Twilio::TwiML::MessagingResponse.new do |resp|
      resp.message(body: "You will recieve a call about your task shortly.")
    end.to_s
    #    end
  end
  def self.get_call h={}
    TWILIO.set_job h['From']
    if h['Digits']
      if h['From'] != CONF['owner']
        j = Redis::HashKey.new("callcenter:jobs")[h['From']]
        TWILIO.sendSms(CONF['owner'], "[#{j}] #{h['From']}")
      end
      @o = Twilio::TwiML::VoiceResponse.new do |resp|
        resp.say(voice: 'male', message: 'goodbye' )
      end.to_s
    else
      @o = Twilio::TwiML::VoiceResponse.new do |resp|
        resp.gather(action: '/call',
                    input: 'dtmf speech',
                    method: GET,
                    timeout: 5) { |g|
          g.say(voice: 'male', message: CONF['callcenter']['welcome'] + ", please leave a message and ou will recieve a call about your task shortly" )
        }
      end.to_s
    end
    return @o
  end
end
