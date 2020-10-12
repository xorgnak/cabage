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
