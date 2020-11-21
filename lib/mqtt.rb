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
  def self.do t, jj
    j = JSON.parse jj
    log "do", "#{t} #{j}"
    if j['org']
      o = Organizer.new(j['id'])
      o.text.value = j['org']
      o.std!
      o.organize!
      Profile.new(j['id']).push({ action: 'w', element: 'div#organizer', payload: o.html.value}) 
    end
  end
end
