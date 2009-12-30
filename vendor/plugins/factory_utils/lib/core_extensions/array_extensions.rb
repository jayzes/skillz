module CoreExtensions
  module ArrayExtensions
    def duplicates
       uniq.select{ |e| (self-[e]).size < self.size - 1 }
    end
  end
end

class Array
  include CoreExtensions::ArrayExtensions
end