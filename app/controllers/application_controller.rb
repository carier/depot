# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  layout "store"

  before_filter :authorize, :except => :login

  helper :all # include all helpers, all the time
  protect_from_forgery :secret => '8fc080370e56e929a2d5afca5540a0f7' # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

protected
  def authorize
    session[:is_first] = 1 if User.count == 0
    unless User.count == 0 || User.find_by_id(session[:user_id])
      session[:original_uri] = request.request_uri
      flash[:notice] = "Please log in"
      redirect_to :controller => 'admin' , :action => 'login'
    end
  end

end
