class DocumentsController < ApplicationController
  def index
    @documents = Repository.all
  end

  def new
    @repo = Repository.new :name => params[:name]
    Rails.logger.info("Params = #{params.inspect}")
  end

  def create
    Repository.new_document params[:repository][:name]
    redirect_to :index
  end

  def find_by_name
    @repo = Repository.by_name(params[:docname]).first || Repository.new_document(params[:docname])
    @repository = @repo.bare_repository
    @branch = params[:branch] || 'master'
    @content = @repo.bare_content @branch
    render :action => :show
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
