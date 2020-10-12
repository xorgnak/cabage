module Components

  def self.badge g
    a = g.attr.all
    return %[<span class='material-icons' style='border-radius: #{a['shape']}; border: thick #{a['style']} #{a['bd']}; background-color: #{a['bg']}; color: #{a['fg']};'>#{a['icon']}</span>]
  end

end
  
