def handleMqtt m,t
  j = JSON.parse(t)
  Redis.new.publish(m,HandleMqtt.do(j[:do] || m || 'ping', j))
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
