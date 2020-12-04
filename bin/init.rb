require 'json'
require 'mqtt'
require 'base64'
require 'redis-objects'
require 'sinatra/base'
require 'thin'
require 'pry'
require 'twilio-ruby'
begin
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
load 'bin/shell.rb'
rescue => err
  log("Error", err.full_message)
end 
