# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'e7c8bfd07804642d488d08d5c56ed35a'

  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  #

  def current_clone(repository)
    @clone_map ||= {}
    return @clone_map[repository] if @clone_map.has_key? repository
    clone_id_map = session[:clone_ids] ||= {}
    if clone_id_map.has_key? repository.id
      ret = ClonedRepository.find clone_id_map[repository.id]
    else
      ret = repository.clone_for_edit
      clone_id_map[repository.id] = ret.id
    end
    @clone_map[repository] = ret
  end

end
