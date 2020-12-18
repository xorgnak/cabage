require 'ruby_mud'
require 'pry'
class MudServer::DefaultController
  def on_start
    send_text "READY. #{session} #{params}"
    transfer_to TheGate
  end
  def allowed_methods; ['gate']; end
  def gate
    transfer_to TheGate
  end
end

class TheGate < MudServer::AbstractController
  def on_start
    send_text "TO LOGIN:"
    send_text "AUTH <username> <password>"
  end
  def allowed_methods; ['auth']; end
  def auth
    send_text "Okay, #{params.split(' ')[0]}. Sit Down."
    transfer_to TheCrowd
  end
end


class TheCrowd < MudServer::AbstractController
  def on_start
    send_text "*** You Sit."
  end
  def allowed_methods
    ['stand']
  end
  def stand
    transfer_to TheStage
  end
end

class TheStage < MudServer::AbstractController
  def on_start
    send_text "*** You Stand."
  end
  def allowed_methods
    ['say', 'do', 'sit']
  end
  def say
    send_text "#{params} #{session}"
  end
  def do
    send_text "#{params}"
  end
  def sit
    transfer_to TheCrowd 
  end
end
@server = MudServer.new
@server.start
binding.pry
