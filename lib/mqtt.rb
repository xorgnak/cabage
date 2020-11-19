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
    if j['form']
      h = {}
      j['form'].split("&").each {|e| ee = e.split("="); h[ee[0]] = ee[1] }
      j['form'] = JSON.generate(h)
    end
    if @@BLOCKS.has_key? n
      @@BLOCKS[n].call(j)
    else
      b = lambda { |h| log("#{n}", "#{h}" ); j }
      b.call(j)
    end
  end
  def self.blocks
    @@BLOCKS.keys
  end
end
