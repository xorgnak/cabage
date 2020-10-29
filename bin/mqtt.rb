def handleMqtt m,t
  j = JSON.parse(m)
  puts "handleMqtt #{j}"
  if j.has_key?(:do) && HandleMqtt.blocks.include?(j[:do])
    d = j[:do]
  else
    d = 'ping'
  end
  HandleMqtt.do(d, j)
  Redis.new.publish(t, m) 
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
                   tx = t.to_datetime
                   mqttSend({ to_i: t.to_i, utc: tx }, "time")
                   sleep 10
                 end

               })
