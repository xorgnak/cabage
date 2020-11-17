class Organizer
  include Redis::Objects
  value :html
  list :text
  hash_key :attr
  sorted_set :stat
  hash_key :todo
  hash_key :done
  hash_key :opts
  def initialize i
    @id = i
  end
  def std!
    self.opts.clear
    {
      'stat':'t',
      'html-postamble':'nil',
      'H':'1',
      'num':'nil',
      'toc':'t',
      '\n':'nil',
      ':':'nil',
      '|':'t',
      '^':'t',
      'f':'t',
      'tex':'t'
    }.each_pair {|k,v| self.opts[k] = v }
  end
  def id; @id; end
  def << i
    td, op = [], []
    td << "TODO(t!/@)"
    self.todo.each_pair {|k,v| td << "#{k.upcase}(#{v}!/@)" }
    td << "|"
    self.done.each_pair {|k,v| td << "#{k.upcase}(#{v}!/@)" }
    td << "DONE(d!/@)"
    self.opts.each_pair {|k,v| op << "#{k}:#{v}" }
    File.open("index.org", 'w') { |f|
      f.write(%[#+TODO: #{td.join(" ")}\n])
      f.write(%[#+OPTIONS: #{op.join(" ")}\n\n])
      f.write(self.text.entries.join("\n"))
    }
    `emacs index.org --batch -f org-html-export-to-html --kill`
    self.html.value = File.read("index.html")
  end
end
