require 'test_helper'

class <%= controller_class_name %>ControllerTest < ActionController::TestCase
  context "<%= file_name %> controller" do
    setup do
      @<%= singular_name %> = <%= singular_name %>_create_with
    end

    context "on GET to :index" do
      setup { get :index }
      
      should_assign_to :<%= plural_name %>
      should_respond_with :success
      should_render_template '<%= controller_file_path %>/index'
    end
    
    context "on GET to :show" do
      setup { get :show, :id => @<%= singular_name %>.id }
      
      should_assign_to :<%= file_name %>
      should_respond_with :success
      should_render_template '<%= controller_file_path %>/show'
    end

    context "on GET to :new" do
      setup { get :new }
      
      should_assign_to :<%= file_name %>
      should_respond_with :success
      should_render_template '<%= controller_file_path %>/new'
      
      context "and submit form" do
        setup do
          submit_form do |form|
            form.<%= file_name %>.update(<%= file_name %>_attributes())
          end
        end

         should_change '<%= model_name %>.count', :by => 1
         should_assign_to :<%= file_name %>
         should_redirect_to '<%= plural_route_path %>_path'
      end
      
    end
    
    context "on GET to :edit" do
      setup { get :edit, :id => @<%= singular_name %>.id }
      
      should_assign_to :<%= singular_name %>
      should_respond_with :success
      should_render_template '<%= controller_file_path %>/edit'
      
      context "and submit form" do
        setup do
          submit_form do |form|
            form.<%= file_name %>.update(<%= file_name %>_attributes(:<%= default_attribute_name %> => <%= default_attribute_value %>))
          end
        end

         should_change '<%= model_name %>.find(@<%= singular_name %>.id).<%= default_attribute_name %>'
         should_assign_to :<%= file_name %>
         should_redirect_to 'edit_<%= singular_route_path %>_path(@<%= singular_name %>)'
      end
    end
    
    context "stubbed valid <%= singular_name %>" do
      setup do
        <%= model_name %>.any_instance.stubs(:valid?).returns(true)
      end 
      
      context "on POST to :create" do
        setup do
          post :create, :<%= singular_name %> => <%= singular_name %>_attributes
        end

        should_change '<%= model_name %>.count', :by => 1
        should_assign_to :<%= file_name %>
        should_redirect_to '<%= plural_route_path %>_path' 
        
        should "save to db" do
          deny assigns(:<%= singular_name %>).new_record?
        end
      end
      
      context "on PUT to :update" do
        setup do
          put :update, :id => @<%= singular_name %>.id, :<%= singular_name %> => { :<%= default_attribute_name %> => <%= default_attribute_value %> }
        end

        should_change '<%= model_name %>.find(@<%= singular_name %>.id).<%= default_attribute_name %>'
        should_assign_to :<%= file_name %>
        should_redirect_to 'edit_<%= singular_route_path %>_path(@<%= singular_name %>)' 
      end
    end
    
    context "stubbed invalid <%= singular_name %>" do
      setup do
        <%= model_name %>.any_instance.stubs(:valid?).returns(false)
      end 
      
      context "on POST to :create" do
        setup do
          post :create, :<%= singular_name %> => <%= singular_name %>_attributes
        end

        should_not_change '<%= model_name %>.count'
        should_assign_to :<%= file_name %> 
        should_render_template '<%= controller_file_path %>/new'
        
        should "not save to db" do
          assert assigns(:<%= singular_name %>).new_record?
        end
      end
      
      context "on PUT to :update" do
        setup do
          put :update, :id => @<%= singular_name %>.id, :<%= singular_name %> => { :<%= default_attribute_name %> => <%= default_attribute_value %> } 
        end

        should_not_change '<%= model_name %>.find(@<%= singular_name %>.id).<%= default_attribute_name %>'
        should_assign_to :<%= file_name %>
        should_render_template '<%= controller_file_path %>/edit' 
      end
    end
    
    context "on DELETE to :destroy" do
      setup { get :destroy, :id => @<%= singular_name %>.id }
      
      should_change '<%= model_name %>.count', :by => -1
      should_assign_to :<%= file_name %>
      should_redirect_to '<%= plural_route_path %>_path'
    end
    
  end

end
