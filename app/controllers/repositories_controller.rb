class RepositoriesController < ApplicationController
  before_filter :login_required
  def new_for_parent
    @parent_repository = Repository.find params[:parent_repo_id]
  end

  def create_for_parent
    parent_repository = Repository.find params[:parent_repo_id]
    new_repository = Repository.create! :parent => parent_repository, :name => params[:name]
    redirect_to :controller => :documents, :action => :find_by_name, :docname => parent_repository.document.name, :repo => new_repository.name
  end

  def edit
    @repository = Repository.find params[:id]
  end

  def update
    repository = Repository.find params[:id]
    repository.content = params[:content]
    repository.commit_message = "Changed by #{current_user.login} (#{params[:commit_message]})"
    repository.save!
    redirect_to :controller => :documents, :action => :find_by_name, :docname => repository.document.name, :repo =>repository.name
  end

end
