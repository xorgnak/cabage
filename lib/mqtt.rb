def mqttSend(o, t)        
  MQTT::Client.connect('localhost') do |client|
    if o.class == String
      oo = o
    else
      oo = JSON.generate(o)
    end
    client.publish(t, oo) 
  end
end

def push_to_user(u, e, v)
  mqttSend({ action: h[:action], element: h[:element], payload: h[:payload]}, "#{CONF{'network'}}/#{u}")
end

module HandleMqtt
  @@BLOCKS = {}
  def self.mk n, &b
    @@BLOCKS[n] = b
  end
  def self.do n, jj
    j = JSON.parse jj
    log "do", "#{n} #{j}"
    if j['org']
      o = Organizer.new(j['id'])
      o.text.value = j['org']
      o.std!
      o.organize!
      Profile.new(@id).push({ action: 'w', element: 'div#organizer', payload: o.html.value}) 
    end
  end
  def self.blocks
    @@BLOCKS.keys
  end
end
