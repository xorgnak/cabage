

class JS

  def initialize u
    @u = u
  end
  def qrcode
    return %[$('#qrcode').qrcode("https://vango.me/ui?id=#{@u}");]
  end
  def venmo
    return %[  function venmo(o) {
      var oo = "venmo://paycharge?txn=";                                               
      oo += o.txn;                                                                     
      oo += "&recipients=";                                                            
      oo += o.recipients;                                                              
      oo += "&amount=";                                                                
      oo += o.amount;                                                                  
      oo += "&note=";                                                                  
      oo += o.note;                                                                    
      return oo                                                                        
  } ]
  end
  def venmo_tip v
    return %[venmo://paycharge?txn=pay&recipients=#{v}&amount=100&note=thanks!]
  end
  def mqtt_init 
      return %[client = new Paho.MQTT.Client('#{CONF['mqtt']['broker']}', Number(#{CONF['mqtt']['port']}), "#{@u}"); client.onConnectionLost = onConnectionLost; client.onMessageArrived = onMessageArrived; client.connect({onSuccess:onConnect, onFailure: onFail, useSSL: true, userName: "#{@u}", password: "#{@tok}"});]
    end
  def mqtt_lib
    t = []; 64.times { t << rand(16).to_s(16) }
    @tok = t.join('');
    ch = %[client.subscribe('#{CONF['network']}/#{@u}'); ]
return %[var token = '#{@tok}';                                                              var state = 0; 
var user;
function onMessageArrived(message) {
  var topic = message.destinationName
  var j = JSON.parse(message.payloadString);
  #{arv[0]}
  if (topic == "time") {
     $("#hour").text(j.hour);
     $("#min").text(j.min);
  } else if (topic == "ping") {
     sendMQTT();
  } else {
     $("div#msgs").prepend("<p><span>" + topic + "</span><code>" + message.payloadString + "</code></p>");
  }
  console.log("onMessageArrived", topic, message);
}
function onFail() {
client.connect();
}
function onConnect() {
  // Once a connection has been made, make a subscription and send a message.
  console.log("onConnect");
  state++;
  client.subscribe('ping');
  client.subscribe('time');
  #{ch}
}
// called when the client loses its connection                                         
function onConnectionLost(responseObject) {                                            
  if (responseObject.errorCode !== 0) {                                                
state--;
    console.log("onConnectionLost", responseObject);                      
  }
}
function sendMQTT() {
  j = JSON.stringify({ id: '#{@u}', state: state, token: token, user: user, form: unescape($('form').serialize()) });
  console.log('sendMQTT', j);
  message = new Paho.MQTT.Message(j);
  message.destinationName = '#{CONF['network']}';
  client.send(message);
} 

]
    
  end
  
end
