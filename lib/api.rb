class API
  def initialize
    @b = {}
  end
  def run k, p={}
    @b[k].call(p)
  end
  def mk k, &v
    @b[k] = v
  end
  
end

@api = API.new
@api.mk(:card) { |p| BusinessCard.new(p['id'])  }
