class Test::Unit::TestCase
  
  def self.should_have_attribute(name, example = nil)
    klass = self.name.gsub(/Test$/, '').constantize
    example ||= klass.new
    should "have a #{name} attribute" do
      assert example.respond_to?(name)
    end
  end
  
end