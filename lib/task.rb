class Task
  include Redis::Objects
  hash_key :attr
  sorted_set :stat
  def initialize(i)
    @id = i
  end
  def id; @id; end
end
