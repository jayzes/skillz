require 'test_helper'

class PeopleControllerTest < ActionController::TestCase

  test "should create person" do
    Person.any_instance.expects(:save).returns(true)
    post :create, :person => { }
    assert_response :redirect
  end

  test "should handle failure to create person" do
    Person.any_instance.expects(:save).returns(false)
    post :create, :person => { }
    assert_template "new"
  end

  test "should destroy person" do
    Person.any_instance.expects(:destroy).returns(true)
    delete :destroy, :id => people(:one).to_param
    assert_not_nil flash[:notice]    
    assert_response :redirect
  end

  test "should handle failure to destroy person" do
    Person.any_instance.expects(:destroy).returns(false)    
    delete :destroy, :id => people(:one).to_param
    assert_not_nil flash[:error]
    assert_response :redirect
  end

  test "should get edit for person" do
    get :edit, :id => people(:one).to_param
    assert_response :success
  end

  test "should get index for people" do
    get :index
    assert_response :success
    assert_not_nil assigns(:people)
  end

  test "should get new for person" do
    get :new
    assert_response :success
  end

  test "should get show for person" do
    get :show, :id => people(:one).to_param
    assert_response :success
  end

  test "should update person" do
    Person.any_instance.expects(:save).returns(true)
    put :update, :id => people(:one).to_param, :person => { }
    assert_response :redirect
  end

  test "should handle failure to update person" do
    Person.any_instance.expects(:save).returns(false)
    put :update, :id => people(:one).to_param, :person => { }
    assert_template "edit"
  end

end