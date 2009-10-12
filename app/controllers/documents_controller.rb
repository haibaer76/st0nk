class DocumentsController < ApplicationController

  before_filter :login_required, :only => :create

  def index
    @documents = Repository.all
  end

  def new
    @repo = Repository.new :name => params[:name]
    Rails.logger.info("Params = #{params.inspect}")
  end

  def create
    doc_name = params.has_key?(:repository) ? params[:repository][:name] : nil
    doc_name ||= params[:name]
    Repository.new_document(doc_name, current_user)
    redirect_to :action => :find_by_name, :docname => doc_name
  end

  def find_by_name
    @repo = Repository.by_name(params[:docname]).first
    if @repo.nil?
      @name = params[:docname]
      render :action => :create_new
    else
      @repository = @repo.bare_repository
      branch_name = params[:branch] || 'master'
      @branch = @repo.branches.by_name(branch_name).first
      if @branch.nil?
        redirect_to :controller => :branches, :action => :new, :name => branch_name, :repository_id => @repo.id
      else
        @content = @repo.bare_content @branch.name
        render :action => :show
      end
    end
  end

  def show
    @repo = Repository.find params[:id]
    branch = params[:branch] || 'master'
    @repository = @repo.repository
    @content = @repo.content
  end

  def edit
    @repo = Repository.find params[:id]
    @branch_name = params[:branch_name] || 'master'
    session[:current_branch_name] = @branch_name
    session[:current_repository_id] = @repo.id
    @dir_id, clone = @repo.clone_for_edit
    clone.checkout @branch_name
    @edit_content = clone.gtree(@branch_name).blobs[STONK_CONFIG.document_name].contents
  end

  def update
    dirname = "#{STONK_CONFIG.working_copies_path}/#{params[:dir_id]}"
    doc_filename = "#{dirname}/#{STONK_CONFIG.document_name}"
    File.open doc_filename, "w" do |f|
      f.write params[:content]
    end
    repo = Git.open dirname
    repo.commit_all params[:remarks]
    done = false
    conflict = false
    while !done
      done = true
      begin
        repo.push
      rescue Git::GitExecuteError
        repo.pull
        done = false
        begin
          repo.merge "origin/#{session[:current_branch_name]}"
        rescue Git::GitExecuteError
          flash[:notice] = "Es gab einen Konflikt"
          @repo = Repository.find session[:current_repository_id]
          @branch_name = session[:current_branch_name]
          @dir_id = params[:dir_id]
          @edit_content = ""
          File.open doc_filename, "r" do |f|
            while content = f.gets
              @edit_content << content
            end
          end
          return render :action => :edit
        end
      end
    end
    FileUtils.rm_rf dirname
    redirect_to "/docs/#{params[:repo_name]}.#{params[:branch_name]}"
  end

  def diff
  end

  def branches
  end

end
