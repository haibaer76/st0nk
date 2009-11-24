class AccountController < ApplicationController
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie

  # say something nice, you goof!  something sweet.
  def index
    redirect_to(:action => 'signup') unless logged_in? || User.count > 0
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(:controller => '/documents', :action => 'index')
      flash[:notice] = "Erfolgreich angemeldet"
    else
      flash[:notice] = "Benutzername oder Passwort falsch!"
    end
  end

  def signup
    @title = "Neuen Account anlegen"
    @user = User.new(params[:user])
    return unless request.post?
    @user.save!
    self.current_user = @user
    redirect_back_or_default(:controller => '/documents', :action => 'index')
    flash[:notice] = "Danke f&uuml;r Die Registrierung!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end
  
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "Sie wurden vom System abgemeldet."
    redirect_back_or_default(:controller => '/documents', :action => 'index')
  end
end
