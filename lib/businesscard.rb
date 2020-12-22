class BusinessCard
  include Redis::Objects
  def initialize i
    @id = i
    @p = Profile.new(@id).attr.all
    @q = RQRCode::QRCode.new(@p['qrcode'], size: 1, level: :l).as_png.to_s
    ls = []; @p['points'].split(' | ').each { |e| ls << %[<li>#{e}</li>] }
    @h = [%[<fieldset><legend>#{@p['title']}</legend>],
          %[<div><h1>#{@p['name']}</h1><img src='data:image/png;base64,#{Base64.encode64(@q)}'><h3>#{@p['pitch']}</h3></div>],
          %[<div><ul>#{ls.join('')}</ul></div></fieldset>]
         ].join('')
  end
  def id; @id; end
  def print r,c
    o = []
    o << %[<span>]
    r.times do |rr|
      c.times { |cc|
        if cc == 0 && rr == 0;
          o << %[<span class='cell ex'>];
        else;
          o << %[<span class='cell'>];
        end;
        o << @h
      } 
      o << %[</span>]
    end
    o << %[</span>]
    
    return o.join('')
  end
end


