def handleMqtt t, m
  Redis.new.publish('DEBUG.##', "#{t} #{m}") 
  HandleMqtt.do(m)
end

Process.detach( fork {                                                                 
                  MQTT::Client.connect('localhost') do |client|                        
                    client.get('#') do |m,t|
                      Redis.new.publish('DEBUG.#', "#{t} #{m}") 
                      handleMqtt(t, m)
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
                   mqttSend(JSON.generate(h), "time")
                   sleep 10
                 end
               })
