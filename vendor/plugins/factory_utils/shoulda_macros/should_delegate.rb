module Test
  module Unit
    class TestCase
      def self.should_delegate(method, opts)
        name = self.name.gsub(/Test$/, '').tableize.singularize
        to = opts[:to]
        should "delegate #{method.to_s} to #{to.to_s}" do  
          from = opts[:from] || instance_variable_get('@' + name) || Factory(name)
          from.send(to).class.any_instance.expects(method).with().at_least_once.returns(true)
          assert from.send(method)
        end
      end
    end
  end
end