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
  end
  def std!
    self.opts.clear
    {
      'stat':'t',
      'html-postamble':'nil',
      'H':'1',
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
    self.file.value = Base64.encode64(File.read("index.org")) 
    self.html.value = /<body>(.*)<\/body>/m.match(File.read("index.html"))[1]
  end
end
