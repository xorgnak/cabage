bot = Cinch::Bot.new do
  configure do |c|
    c.nick = Redis.new.get('ID')
    c.server = 'vango.me'
    c.verbose = true
    c.channels = ["#hive", "##{c.nick}"]
  end
  
  on(:catchall) do |m|
    Handle::Irc.new(m)
  end
end

Process.detach( fork { bot.start } )
