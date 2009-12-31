require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase

  test "should create project" do
    Project.any_instance.expects(:save).returns(true)
    post :create, :project => { }
    assert_response :redirect
  end

  test "should handle failure to create project" do
    Project.any_instance.expects(:save).returns(false)
    post :create, :project => { }
    assert_template "new"
  end

  test "should destroy project" do
    Project.any_instance.expects(:destroy).returns(true)
    delete :destroy, :id => projects(:one).to_param
    assert_not_nil flash[:notice]    
    assert_response :redirect
  end

  test "should handle failure to destroy project" do
    Project.any_instance.expects(:destroy).returns(false)    
    delete :destroy, :id => projects(:one).to_param
    assert_not_nil flash[:error]
    assert_response :redirect
  end

  test "should get edit for project" do
    get :edit, :id => projects(:one).to_param
    assert_response :success
  end

  test "should get index for projects" do
    get :index
    assert_response :success
    assert_not_nil assigns(:projects)
  end

  test "should get new for project" do
    get :new
    assert_response :success
  end

  test "should get show for project" do
    get :show, :id => projects(:one).to_param
    assert_response :success
  end

  test "should update project" do
    Project.any_instance.expects(:save).returns(true)
    put :update, :id => projects(:one).to_param, :project => { }
    assert_response :redirect
  end

  test "should handle failure to update project" do
    Project.any_instance.expects(:save).returns(false)
    put :update, :id => projects(:one).to_param, :project => { }
    assert_template "edit"
  end

end