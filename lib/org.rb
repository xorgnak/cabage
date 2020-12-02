class Organizer
  include Redis::Objects
  value :html
  value :text
  value :file
  hash_key :attr
  sorted_set :stat
  hash_key :todo
  hash_key :done
  hash_key :opts
  def initialize i
    @id = i
    @u = Profile.new(i)
    if self.text.value == nil
      self.text.value = [%[* welcome to the road],
                         %[- You'll find useful tools like the organizer and profle editor in the menu on the top left.],
                         %[- Time, location stamps can be added to you organizer with their buttons above.],
                         %[- When an update is pending, add your status and click the green button to record your entry.],
                        %[- Safe travels!]].join("\n")
    end
  end
  def std!
    self.opts.clear
    {
      'stat':'t',
      'html-postamble':'nil',
      'H':'6',
      'num':'nil',
      'toc':'nil',
      '\n':'nil',
      ':':'nil',
      '|':'t',
      '^':'t',
      'f':'t',
      'tex':'t'
    }.each_pair {|k,v| self.opts[k] = v }
  end
  def id; @id; end
  def organize!
    if m = /(\*+\s([\w\s]+)(:\w+:)([\w\s]*))/m.match(self.text.value)
      m.each { |e| e[e].split(":").each {|ee| Group.new(ee) << "+1" + @id } }
    end
    td, op = [], []
    td << "TODO(t!/@)"
    self.todo.all.each_pair {|k,v| td << "#{k.upcase}(#{v}!/@)" }
    td << "|"
    self.done.all.each_pair {|k,v| td << "#{k.upcase}(#{v}!/@)" }
    td << "DONE(d!/@)"
    self.opts.all.each_pair {|k,v| op << "#{k}:#{v}" }
    File.open("index.org", 'w') { |f|
      f.write(%[#+TODO: #{td.join(" ")}\n])
      f.write(%[#+OPTIONS: #{op.join(" ")}\n])
      f.write(%[#+TITLE: #{self.attr['title']}\n\n]);
      f.write(self.text.value)
    }
    `emacs index.org --batch -f org-html-export-to-html --kill` 
    #    self.html.value = /<body>(.*)<\/body>/m.match(File.read("index.html"))[1]
    self.html.value = File.read("index.html")
  end
end
