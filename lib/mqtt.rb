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

module HandleMqtt
  @@BLOCKS = {}
  def self.mk n, &b
    @@BLOCKS[n] = b
  end
  def self.do n, jj
    j = JSON.parse jj
    log "do", "#{n} #{j}"
    if n != 'ping' && n != 'time'
      o = Organizer.new(j['id'])
      o.text.value = j['org']
      o.std!
      o.organize!
    end
  end
  def self.blocks
    @@BLOCKS.keys
  end
end
