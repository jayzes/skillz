module Test
  module Unit
    class TestCase
      def self.should_have_valid_factory(factory = nil)
        klass = model_class
        factory = factory || model_class.name.underscore.to_sym
        should "build and save a valid object from factory #{factory}" do
         model = Factory.build(factory)
         assert model.save, model.errors.full_messages.to_sentence
        end
        
        should "create a valid object from factory #{factory}" do
         model = Factory.create(factory)
         assert !model.new_record?, model.errors.full_messages.to_sentence
        end
      end
    end
  end
end