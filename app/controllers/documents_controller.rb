class DocumentsController < ApplicationController
  def index
    @documents = Repository.all
  end

  def new
    @repo = Repository.new
  end

  def create
    Repository.new_document params[:repository][:name]
    redirect_to :index
  end

  def show
    @repo = Repository.find params[:id]
    branch = params[:branch] || 'master'
    @repository = @repo.repository
    @content = @repo.content
  end

  def diff
  end

  def branches
  end

end
