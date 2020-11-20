def handleMqtt m,t
  Redis.new.publish('DEBUG.##', "#{t} #{m}") 
  Redis.new.publish(t || 'ping', HandleMqtt.do(t, m))
end

Process.detach( fork {                                                                 
                  MQTT::Client.connect('localhost') do |client|                        
                    client.get('#') do |t, m|
                      Redis.new.publish('DEBUG.#', "#{t} #{m}") 
                      handleMqtt(m, t)
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
