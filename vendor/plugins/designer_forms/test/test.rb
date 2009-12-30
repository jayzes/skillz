require 'rubygems'
require 'test/unit'

require 'action_view/helpers/form_helper'
require 'action_view/helpers/form_tag_helper'
require 'action_view/helpers/active_record_helper'

require File.dirname(__FILE__) + '/../lib/designer_forms/designer_form_builder.rb'


class DesignerFormsTest < Test::Unit::TestCase

  # This is the helper with the 'tag' method
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::ActiveRecordHelper
  include DesignerForms::HelperExtensions

  def test_add_class_method
    options = {:class => 'test'}
    add_class!(options, 'class')
    output = content_tag(:div, 'testing add_class!', options)
    assert_equal '<div class="test class">testing add_class!</div>', output
  end

end
