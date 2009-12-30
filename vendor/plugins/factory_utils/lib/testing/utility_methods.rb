# Module with a variety of helpful Testing utility methods.
require 'factory_girl'

module Testing::UtilityMethods
  
  def self.included(base)
    [ModelAssertions, FunctionalAssertions, ConvenienceHelpers].each { |m| base.send(:include, m) }
    base.extend TestSuiteMethods
  end
  
  # Methods designed to be called at the suite level.
  module TestSuiteMethods
    
    
  end
  
  # Non-specific methods used in the ConvenienceMethods module
  module ConvenienceHelpers
    # Remove any hash entries whose values are nil.  Used to keep overridden nil values from 
    # being passed to create and new on models.   
    def strip_nil_values(hash)
      hash.reject { |key, value| value.nil? }
    end
    
    # convenience methods for Factory Girl
    # user_create_with is the same as Factory(:user)
    def method_missing(method_name, *args)
      if /(.*)_create_with/ =~ method_name.to_s
        Factory.create($1, *args) 
      elsif /(.*)_with/ =~ method_name.to_s 
          Factory.build($1, *args)
      elsif /(.*)_attributes/ =~ method_name.to_s 
          Factory.attributes_for($1, *args) 
      else
        super
      end    
    end
  end
  
  module ModelAssertions
    # The opposite of an assert.
    #
    #  deny world.flat?, "A round world was expected, but it was found to be flat."
    def deny(condition, msg = nil)
      assert ! condition, msg
    end
      
    # Simple method to ensure that a model object is invalid, and that it has errors
    # for the attribute that you specified.
    def assert_attribute_required(model, attribute)
      assert !model.valid?, "#{model.class} should be invalid with missing #{attribute}"
      assert_not_nil model.errors.on(attribute), "#{model.class} should have errors on #{attribute}"
    end
    
    # Uses the passed factory_method to generate new model objects.  Will generate one for
    # each field you pass, with that field set to nil.  Will validate that the model is not
    # valid, and has errors on the field you requested.
    def assert_required_fields(attributes, factory_method)
      attributes.each do |attribute|
        # model = self.send(factory_method)
        #         attribute = "#{attribute}_id" if model.class.reflect_on_association(attribute)
        assert_attribute_required(self.send(factory_method, attribute => nil), attribute)
      end
    end
    alias assert_required_field assert_required_fields
    
    def assert_error_on(field, model)
    	assert !model.errors[field.to_sym].nil?, "No validation error on the #{field.to_s} field."
    end

    def assert_no_error_on(field, model)
    	assert model.errors[field.to_sym].nil?, "Validation error on #{field.to_s}."
    end
    
    # Determines that an ActiveRecord object is valid
    def assert_valid(model, failure_message = nil)
      failure_message ||= "#{model.class} should be valid"
      assert model.valid?, failure_message
    end
    
    # Determines that an ActiveRecord is not valid, and optionally has errors on the field passed.
    def assert_invalid(model, field = nil, failure_message = nil)
      failure_message ||= "#{model.class} should have errors on #{field.to_s} field"
      assert !model.valid?, "#{model.class} should not be valid"
      assert_not_nil model.errors.on(field), failure_message if field
    end
    alias assert_not_valid assert_invalid

  end
  
  module FunctionalAssertions
    # For use in functional tests, wraps the common task of determining if an instance variable
    # has been assigned for the view, and also allows you to verify the identity of that object.
    def assert_assigned(symbol, expected = nil, failure_message = nil)
      failure_message ||= "instance variable @#{symbol.to_s} should be #{expected}"
      assert_not_nil assigns(symbol), "controller should have set instance variable @#{symbol.to_s}"
      assert_equal expected, assigns(symbol), failure_message unless expected.nil?
    end
    
    def assert_updated(symbol, attribute, expected = nil, failure_message = nil)
      failure_message ||= "instance variable @#{symbol.to_s}'s attribute #{attribute.to_s} should have been updated."
      expected ||= assigns(symbol).send(attribute.to_s)
      assert_equal expected, assigns(symbol).reload.send(attribute.to_s), failure_message
    end
    
    def assert_not_updated(symbol, attribute, expected = nil, failure_message = nil)
      failure_message ||= "instance variable @#{symbol.to_s}'s attribute #{attribute.to_s} should not have been updated."
      expected ||= assigns(symbol).send(attribute.to_s)
      assert_not_equal expected, assigns(symbol).reload.send(attribute.to_s) 
    end
    
    # Compares a regular expression to the body text returned by a functional test.
    #
    #  assert_match_body /<doctype/
    def assert_match_body(regex)
      assert_match regex, @response.body
    end

    def assert_no_match_body(regex)
      assert_no_match regex, @response.body
    end

    def assert_match_headers(header, regex)
      assert_match regex, @response.headers[header]
    end
  end

end