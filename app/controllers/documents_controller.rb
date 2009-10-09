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
    @dir_id, clone = @repo.clone_for_edit
    clone.checkout @branch_name
    @edit_content = clone.gtree(@branch_name).blobs[STONK_CONFIG.document_name].contents
  end

  def update
    dirname = "#{STONK_CONFIG.working_copies_path}/#{params[:dir_id]}"
    File.open "#{dirname}/#{STONK_CONFIG.document_name}", "w" do |f|
      f.write params[:content]
    end
    repo = Git.open dirname
    repo.commit_all params[:remarks]
    repo.push
    FileUtils.rm_rf dirname
    redirect_to "/docs/#{params[:repo_name]}.#{params[:branch_name]}"
  end

  def diff
  end

  def branches
  end

end
