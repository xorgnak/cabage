HandleMqtt.mk('ping') do |j|
  Redis.new.publish('DEBUG.mqtt.ping', JSON.generate(j))
end
