require 'test_helper'

class SkillsControllerTest < ActionController::TestCase

  test "should create skill" do
    Skill.any_instance.expects(:save).returns(true)
    post :create, :skill => { }
    assert_response :redirect
  end

  test "should handle failure to create skill" do
    Skill.any_instance.expects(:save).returns(false)
    post :create, :skill => { }
    assert_template "new"
  end

  test "should destroy skill" do
    Skill.any_instance.expects(:destroy).returns(true)
    delete :destroy, :id => skills(:one).to_param
    assert_not_nil flash[:notice]    
    assert_response :redirect
  end

  test "should handle failure to destroy skill" do
    Skill.any_instance.expects(:destroy).returns(false)    
    delete :destroy, :id => skills(:one).to_param
    assert_not_nil flash[:error]
    assert_response :redirect
  end

  test "should get edit for skill" do
    get :edit, :id => skills(:one).to_param
    assert_response :success
  end

  test "should get index for skills" do
    get :index
    assert_response :success
    assert_not_nil assigns(:skills)
  end

  test "should get new for skill" do
    get :new
    assert_response :success
  end

  test "should get show for skill" do
    get :show, :id => skills(:one).to_param
    assert_response :success
  end

  test "should update skill" do
    Skill.any_instance.expects(:save).returns(true)
    put :update, :id => skills(:one).to_param, :skill => { }
    assert_response :redirect
  end

  test "should handle failure to update skill" do
    Skill.any_instance.expects(:save).returns(false)
    put :update, :id => skills(:one).to_param, :skill => { }
    assert_template "edit"
  end

end