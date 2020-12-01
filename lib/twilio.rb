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
  def self.get_sms b, h={}
    Twilio::TwiML::MessagingResponse.new do |resp|
      if h['From'] != CONF['owner']
        j = Redis::HashKey.new("callcenter:jobs")[@h['From']]
        TWILIO.sendSms(CONF['owner'], "[#{j}] #{@h['From']} #{@h['Body']}")
        resp.message(body: "You will recieve a call about your task shortly.")
      end 
    end.to_s
  end
  def self.get_call b, h={}
    Twilio::TwiML::VoiceResponse.new do |resp|
      resp.gather(action: '/call', timeout: 10) { |g|
        g.say(message: CONF['callcenter']['welcome'] + ", You will recieve a call about your task shortly" )
      }
      if @h['From'] != CONF['owner']
        j = Redis::HashKey.new("callcenter:jobs")[@h['From']]
        TWILIO.sendSms(CONF['owner'], "[#{j}] #{@h['From']}")
      end 
    end.to_s 
  end
end
