class BranchesController < ApplicationController
  def new
    @repository = Repository.find params[:repository_id]
    @branch = Branch.new :name => params[:name], :repository_id => params[:repository_id]
  end

end
