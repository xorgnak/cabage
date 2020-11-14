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
  def members
    self.profiles.members
  end
  def badge
    a = self.attr.all
    return %[<span class='material-icons' style='border-radius: #{a['shape']}; border: thick #{a['style']} #{a['bd']}; background-color: #{a['bg']}; color: #{a['fg']};'>#{a['icon']}</span>]                                                                        
  end
end 
#team = Hash.new {|h,k| h[k] = Group.new(k) } 
