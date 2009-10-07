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
    @edit_content = @repo.bare_content @branch_name
  end

  def update
    repo = Repository.find params[:id]
    branch = params[:branch_name] || 'master'
    repo.update_content params[:content], params[:remarks], branch
    redirect_to "/docs/#{repo.name}.#{branch}"
  end

  def diff
  end

  def branches
  end

end
