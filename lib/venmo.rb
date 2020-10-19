
require 'uri'
## venmo deeplink generator
# txn: pay|charge
# recipients: who the request goes to
# amount: the txn amount
# note: the contents of the txn
def venmo_add_line_item k,v
  i = 0
  d = ''
  if k == 'install'
    if v['please'] == 'on'
      i += 100
      r = "100 Installation"
    end
    if v['now'] == 'on'
      i += 200
      r = "200 RUSH"
    end
  else
    if v.has_key? 'length'
      if v['style'] == 'sd'
        x = 0.50
      elsif v['style'] == 'hd'
        x = 0.80
      end 
      i += (v['length'].to_i * x).to_i
    else
      if v['style'] == 'sd'
        i += 50
      elsif v['style'] == 'hd'
        i += 100
      end
    end
    if v['2x'] == 'on'
      i += i
      d = '2x'
    end
    r = "#{i} #{v['style']} #{k} #{d}"
  end
  return [r, i]
end
def venmo_order(p)
  n, b, t = [], [], 0
  h = { txn: 'pay', recipients: p['pay'], link: "PAY WITH VENMO"}
  b << %[<h3>#{p['desc']}</h3><ul>]
  p['order'].each_pair { |k,v|
    nt = venmo_add_line_item(k,v);
    b << "<li>+#{nt[0]}</li>"
    n << nt[0];
    t += nt[1]
  }
  b << "<li style='font-weight: bold;'>$#{t} TOTAL</li></ul>"
  n << "$#{t} TOTAL"
  h[:note] = n.join('\n')
  h[:amount] = t
  return %[#{b.join('')}#{venmo(h)}]
end
def venmo h={}
  if h[:recipients].class == String
    r = h[:recipients]
  elsif h[:recipients].class == Array
    r = h[:recipients].join(',')
  end
  l =  %[venmo://paycharge?txn=#{h[:txn]}&recipients=#{r}&amount=#{h[:amount]}&note=#{URI.escape(h[:note] || '')}]
  if h[:link]
    ll = %[<a href='#{l}' class='venmo'>#{h[:link]}</a>]
  else
    ll = l
  end
  return ll
end
