class Product
  include Redis::Objects
  hash_key :attr
  sorted_set :stat
  def initialize h={}
    if h[:id]
      @id = h[:id]
    else
      i = []; 16.times { i << rand(16).to_s(16) }
      return i.join('')
    end
  end
end
