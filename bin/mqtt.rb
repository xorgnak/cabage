def handleMqtt t,m
  Redis.new.publish(t, m) 
end

Process.detach( fork {                                                                 
                  MQTT::Client.connect('localhost') do |client|                        
                    client.get('#') do |topic, message|
                      handleMqtt(topic, message)
                    end                                 
                  end                                                                  
                })

