module Test
  module Unit
    class TestCase
      def self.should_be_authentic
        klass = self.name.gsub(/Test$/, '').constantize
        should "act as authentic" do
          assert klass.respond_to?(:acts_as_authentic_config)
        end
      end
    end
  end
end