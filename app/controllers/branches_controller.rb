class BranchesController < ApplicationController
  def new
    @repository = Repository.find params[:repository_id]
    @branch = Branch.new :name => params[:name], :repository_id => params[:repository_id], :write_access_for => 'public'
  end

  def create
    branch = Branch.create! params[:branch]
    redirect_to "/docs/#{branch.repository.name}.#{branch.name}"
  end

  def merge
    branch = Branch.find params[:merge_destination_id]
    other_branch = Branch.find params[:merge][:merge_source_id]
    clone = branch.repository.clone_for_edit
    repo = clone.git_repo
    begin
      repo.branch("origin/#{branch.name}").checkout
      repo.branch(branch.name).checkout
      repo.branch("origin/#{other_branch.name}").merge
    rescue Git::GitExecuteError
      flash[:notice] = "Es gab einen Konflikt"
      @repo = branch.repository
      @branch_name = branch.name
      @edit_content = ""
      File.open "#{clone.path}/#{STONK_CONFIG.document_name}" do |f|
        while content = f.gets
          @edit_content << content
        end
      end
      return render :controller => :documents, :action => :edit
    end
    repo.push
    clone.destroy
  end

end
