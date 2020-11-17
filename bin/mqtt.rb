def handleMqtt m,t
  j = JSON.parse(m)
  Redis.new.publish(t,HandleMqtt.do(j[:do] || t || 'ping', j))
end

Process.detach( fork {                                                                 
                  MQTT::Client.connect('localhost') do |client|                        
                    client.get('#') do |message, topic|
                      handleMqtt(topic, message)
                    end                                 
                  end                                                                  
                })

Process.detach(fork {

                 loop do
                   t = Time.now
                   h = {
                     hour: t.hour,
                     min: t.min,
                     sec: t.sec,
                     month: t.month,
                     day: t.day,
                     ts: t.to_i,
                     utc: t.to_datetime
                   }
                   mqttSend(h, "time")
                   sleep 10
                 end
               })
