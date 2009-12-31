class SessionsController < ApplicationController
  
  def login
    Casablanca::Rails::Filter.login_url(self)
  end

  def logout
    Casablanca::Rails::Filter.logout(self)
    redirect_to Casablanca::Rails::Filter.logout_url(self)
  end
end