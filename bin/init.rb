require 'json'
require 'mqtt'
require 'redis-objects'
require 'sinatra/base'
require 'thin'
require 'pry'
def log t, m
  if m.class == String
    mm = m
  else
    mm = JSON.generate(m)
  end
  Redis.new.publish("DEBUG.#{t}", mm)
end
log 'cabgo', 'running'
CONF = JSON.parse(File.read('config.json'))
log('CONF', CONF)
Dir['lib/*'].each { |e| log('loaded', e);load e; log('loaded' ,e) }
load 'bin/mqtt.rb'
log 'mqtt', 'running'
load 'bin/web.rb'
log 'web', 'running'
load 'mqtt.rb'                                                                         
puts "HandleMqtt.blocks #{HandleMqtt.blocks}"
load 'bin/shell.rb'
