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
  def self.do n, j
    @@BLOCKS[n].call(j)
  end
  def self.blocks
    @@BLOCKS.keys
  end
end
