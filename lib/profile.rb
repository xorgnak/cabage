class Profile
  include Redis::Objects
  hash_key :attr
  sorted_set :stat
  set :groups
  list :images
  set :products
  def initialize i
    @id = i
  end
  def id; @id; end
  def relationships *q
    self.stat.members(with_scores: true).to_h.each_pair do |k,v|
      self.groups << "#{k}:#{v}"
      Group.new(k) << @id
    end
    if q[0]
      @xp = {}
      @us = Hash.new { |h,k| h[k] = Set.new }
      ['s', 'ing'].each { |e|
        if /#{e}/.match(q[1]);
          @ss = q[1].gsub(/#{e}/, '')
        else
          @ss = q[1]
        end
      }
      self.groups.members.each do |e|
        @xp[:me] = self.stat[e].to_i
        ee = e.split(":")
        @xp[ee[0]] = ee[1].to_i
        if /#{@ss}/.match(Group.new(ee[0]).attr[q[0]])
          @us[q[1]] << ee[0]
        end  
      end
      uss = {}
      @us.each_pair { |k,v| uss[k] = v.map { |e| e } }
      return { weights: @xp, me: self.attr[q[0]], matches: uss }
    else
      return self.groups.members
    end
  end
  def push(h={})
    mqttSend(
      { action: h[:action], element: h[:element], payload: h[:payload] },
      "#{CONF['network']}/#{@id}"
    )
  end 
end
#user = Hash.new {|h,k| h[k] = Profile.new(k) }

class Group        
  include Redis::Objects
  hash_key :attr
  sorted_set :stat
  set :profiles
  set :tasks
  def initialize i
    @id = i
  end
  def id; @id; end
  def << p
    self.profiles << p
  end
  def push(h={})
    self.profiles.members.each {|e| Profile.new(e).push(h) }
  end
  def members
    self.profiles.members
  end
  def badge
    a = self.attr.all
    return %[<span class='material-icons' style='border-radius: #{a['shape']}; border: thick #{a['style']} #{a['bd']}; background-color: #{a['bg']}; color: #{a['fg']};'>#{a['icon']}</span>]                                                                        
  end
end


#team = Hash.new {|h,k| h[k] = Group.new(k) } 
