def handleMqtt m,t
  Redis.new.publish(t || 'ping', HandleMqtt.do(t, m))
end

Process.detach( fork {                                                                 
                  MQTT::Client.connect('localhost') do |client|                        
                    client.get('#') do |topic, message|
                      Redis.new.publish('DEBUG.#', "#{topic} #{message}") 
                      handleMqtt(message, topic)
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
