module CoreExtensions
  module StringExtensions
    def snippet(character_count,omission)
      return self.dup if character_count >= self.size
      words = self.split.reverse
      snippet = ''
      word = words.pop
      while (word && ((snippet.size + word.size) < (character_count + omission.size)))
        snippet << word + ' '
        word = words.pop
      end
      return snippet.strip + omission
    end
    
    def is_zip_code?
      /^\d{5}(-\d{4})?$/.match(self)
    end
  end
end

class String
  include CoreExtensions::StringExtensions
end