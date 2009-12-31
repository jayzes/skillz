# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  include SortableTable::App::Controllers::ApplicationController
  
  before_filter Casablanca::Rails::Filter, :unless => lambda { |c| c.session[:cas_user] && c.send(:current_person).nil? }
  before_filter :check_current_person
  
  helper_method :current_person
  
  protected
  
  
  def current_person
    logger.info "CAS user: #{session[:cas_user]}"
    @current_person ||= Person.find_by_cas_user(session[:cas_user])
  end
  
  def check_current_person
    unless current_person
      flash[:notice] = "It looks like you haven't used Skillz before - to start, please fill out your skill profile"
      flash.keep
      redirect_to new_person_path(:person => {:cas_user => session[:cas_user]})
    end
  end

end
