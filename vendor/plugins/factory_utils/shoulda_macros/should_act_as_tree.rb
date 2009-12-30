module Test
  module Unit
    class TestCase
      def self.should_act_as_tree(options = {})
        klass = self.name.gsub(/Test$/, '').constantize
        should "be able to access its children" do
          k = klass.new
          assert k.respond_to?(:children)
          assert k.children.is_a?(Array)
        end
        
        should "be able to access its siblings" do
          k = klass.new
          assert k.respond_to?(:siblings)
          assert k.siblings.is_a?(Array)
        end
        
        should "be able to access its parent" do
          k = klass.new
          assert k.respond_to?(:parent)
          assert k.parent.is_a?(klass) || k.parent.nil?
        end
        
        should "be able to access its root" do
          k = klass.new
          assert k.respond_to?(:root)
          assert k.root.is_a?(klass) || k.root.nil?
        end
      end
    end
  end
end