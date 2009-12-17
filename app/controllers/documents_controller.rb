class DocumentsController < ApplicationController

  before_filter :login_required, :only => [:create, :new, :edit]

  def index
    @documents = Repository.scoped(:order => :human_name)
  end

  def new
    @repo = Repository.new :name => params[:name]
    Rails.logger.info("Params = #{params.inspect}")
  end

  def create
    r = Repository.create! params[:repository]
    redirect_to :action => :find_by_name, :docname => r.name
  end

  def find_by_name
    @repo = Repository.by_name(params[:docname]).first
      Rails.logger.info "Finding name #{params[:docname]}"
    if @repo.nil?
      @name = params[:docname]
      return render :action => :create_new
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
    @clone = ClonedRepository.create! :original_repository=>@repo
    session[:edit_clone_id] = @clone.id
    @edit_content = @repo.bare_content @branch_name
  end

  def update
    clone = ClonedRepository.find session[:edit_clone_id]
    clone.update_content params[:content], params[:remarks]
    repo = Repository.find params[:id]
    remarks = params[:remarks]
    clone = repo.clone_for_edit

    clone = ClonedRepository.find params[:clone_id]
    doc_filename = "#{clone.path}/#{STONK_CONFIG.document_name}"
    File.open doc_filename, "w" do |f|
      f.write params[:content]
    end
    repo = clone.git_repo
    repo.commit_all params[:remarks]
    done = false
    conflict = false
    while !done
      done = true
      begin
        repo.push "origin", params[:branch_name]
      rescue Git::GitExecuteError
        repo.fetch
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
    clone.destroy
    redirect_to "/docs/#{clone.original_repository.name}.#{params[:branch_name]}"
  end

  def diff
  end

  def branches
  end

end
