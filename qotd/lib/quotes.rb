require 'yaml'

class Quotes
  def self.load(fn)
    self.new(fn)
  end
  
  def initialize(fn=nil)
    if fn
      load(fn)
    end
  end
  
  def load(fn)
    puts "Loading quotes file '#{fn}'"
    @qlist = YAML.load(IO.read(fn))
    @qlist.each_with_index{|qhash, i| qhash[:id] = i; qhash[:text].chomp!}
  end
  
  def [](id)
    @qlist[id]
  end
  
  def random(seed=nil)
    srand(seed) if seed
    @qlist[rand(@qlist.size)]
  end
  
  def search(re, key)
    @qlist.select {|qhash| qhash[key] =~ re }
  end
end