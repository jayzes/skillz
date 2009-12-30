module Test
  module Unit
    class TestCase
      def self.should_act_as_attachment(options = {})
        klass = self.name.gsub(/Test$/, '').constantize
        should "have a 'public_filename' method" do
          k = klass.new
          assert k.respond_to?(:public_filename)
        end
        
        should "have an 'uploaded_data' method" do
          k = klass.new
          assert k.respond_to?(:uploaded_data)
        end
      end
    end
  end
end