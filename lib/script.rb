class Sc
  def initialize u
    @db = Profile.new(u).attr
    @output = []
  end
  def db k
    @db[k]
  end
  def add l
    log("sc.line", "#{l}") 
    if m = /^(?<verb>\w+):\s(?<nouns>.*)$/.match(l)
      log("sc.match", "#{m}")
      if public_methods.include? m[:verb].to_sym
        log("sc.match", %[#{m[:verb]}(#{obj(m[:nouns])});]) 
        self.instance_eval(%[#{m[:verb]}(#{obj(m[:nouns])});])
      else
        log("sc.no_method", %[#{obj(l)}]) 
        @output << "#{l}"
      end
    else
      log("sc.no_match", %[#{obj(l)}])
      @output << "#{obj(l)}"
    end
  end
  def result
    return @output
  end
  def obj o
    begin
      x = JSON.generate(o)
    rescue
      x = o
    end
    oo = []
    x.split(" ").each do |e|
      log('sc.word', e) 
      if /:\.+/.match(e);
        log('sc.word_match', e)
        oo << self.instance_eval(%[db(#{e.gsub(':', '')})]);
      else
        oo << e;
      end
    end
    return oo.join(' ')
  end
  def p l
    @output << %[<p>#{l}</p>]
  end
  def form h={}
    if h[]
      @output << %[]
    else
      @output << %[]
    end
  end 
end

class Script
  def initialize u, s
    @sc = Sc.new(u)
    s.split("\n").each { |l| log("script", l); @sc.add(l) }
  end
  def result
    return @sc.result
  end
end
