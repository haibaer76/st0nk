class Repository < ActiveRecord::Base
  validates_presence_of :path
  validates_presence_of :name
  validates_uniqueness_of :name

  @@DOCUMENT_NAME = "the_doc"

  class << self
    def new_document(name, options={}, &block)
      content = options.delete(:content) || "A New Document"
      repo = create!(options) do |r|
        r.name = name
        r.path = gen_path(name)
        yield r if block_given?
      end
      grit_repo = Grit::Repo.init_bare(repo.path)
      i = grit_repo.index
      i.add(@@DOCUMENT_NAME, content)
      i.commit("init")
    end

    def gen_path(name)
      "/home/feson/stonk/repositories/#{Base64.encode64(name).strip}.git"
    end
  end

  def repository
    if @the_repo.nil?
      @the_repo = Grit::Repo.new path
    end
    @the_repo
  end

  def content(branch='master')
    (repository.tree(branch)./"#{@@DOCUMENT_NAME}").data
  end
end
