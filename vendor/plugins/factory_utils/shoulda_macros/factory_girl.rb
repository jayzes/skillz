module Test
  module Unit
    class TestCase
      def self.should_have_factory(model)
        klass = self.name.gsub(/Test$/, '').constantize
        should "have a factory for #{model}" do
          m = Factory(model)
          assert m.is_a?(klass)
          assert m.valid?
        end
      end
    end
  end
end