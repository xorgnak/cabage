
require 'uri'
## venmo deeplink generator
# txn: pay|charge
# recipients: who the request goes to
# amount: the txn amount
# note: the contents of the txn
def venmo h={}
  if h[:recipients].class == String
    r = h[:recipients]
  elsif h[:recipients].class == Array
    r = h[:recipients].join(',')
  end
  l =  %[venmo://paycharge?txn=#{h[:txn]}&recipients=#{r}&amount=#{h[:amount]}&note=#{URI.escape(h[:note])}]
  if h[:link]
    ll = %[<a href='#{l}' class='venmo'>#{h[:link]}</a>]
  else
    ll = l
  end
  return ll
end
