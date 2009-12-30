class Test::Unit::TestCase
  def model_class
    self.class.model_class
  end
  def self.model_class
    self.name.gsub(/Test$/, '').constantize
  end
end