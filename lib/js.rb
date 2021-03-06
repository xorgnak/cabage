

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
  def venmo_tip v, m
    t = URI.encode(m)
    return %[venmo://paycharge?txn=pay&recipients=#{v}&amount=100&note=#{t}]
  end
  def mqtt_init 
      return %[client = new Paho.MQTT.Client('#{CONF['mqtt']['broker']}', Number(#{CONF['mqtt']['port']}), "#{@u}"); client.onConnectionLost = onConnectionLost; client.onMessageArrived = onMessageArrived; client.connect({onSuccess:onConnect, onFailure: onFail, useSSL: true, userName: "#{@u}", password: "#{@tok}"});]
    end
  def mqtt_lib
    t = []; 64.times { t << rand(16).to_s(16) }
    @tok = t.join('');
    ch = %[client.subscribe('#{CONF['network']}/#{@u}'); ]
	     return %[
		 var token = '#{@tok}';
		 var state = 0; 
		 var pos_item = 0;
		 var loc_num = 0;
		 var ven;
		 var user;
		 function onMessageArrived(message) {
		     var topic = message.destinationName;
		     var j = JSON.parse(message.payloadString);
		     if (topic == "time") {
			 if (j.hour < 10) {
			     $("#hour").text("0" + j.hour);
			 } else {
			     $("#hour").text(j.hour);
			 }
			 if (j.min < 10) {
			     $("#min").text("0" + j.min);
			 } else {
			     $("#min").text(j.min);
			 }
		     } else if (topic == "ping") {
			 sendMQTT();
		     } else if (j.action == 'w') {
			 $(j.element).html(j.payload);
		     } else if (j.action == 'a') { 
			 $(j.element).append(j.payload);
		     } else if (j.action == 'p') { 
			 $(j.element).prepend(j.payload);
		     }
		     console.log("onMessageArrived", topic, j);
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
		     //var ti = { txn: 'pay', recipients: '<%= @attr['venmo'] %>', amount: 20, note: "tips appreciated" }
		     //ven = encodeURI(venmo(ti));
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
		     var ua = $('form').serializeArray();
		     var ia = {};
		     $.map(ua, function(n, i){ ia[n['name']] = n['value']; });
		     ia['id'] = '#{@u}';
		     ia['state'] = state;
		     ia['token'] = token;
		     ia['user'] = user;
		     ia['venmo'] = ven;
		     console.log('sendMQTT',ia);
		     message = new Paho.MQTT.Message(JSON.stringify(ia));
		     message.destinationName = '#{CONF['network']}';
		     client.send(message);
		 } 
		 
	     ]
    
  end
  
end
