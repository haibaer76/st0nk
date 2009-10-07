class Repository < ActiveRecord::Base
  validates_presence_of :path
  validates_presence_of :name
  validates_uniqueness_of :name

  named_scope :by_name, lambda{|name|
    {:conditions => {:name => name}}
  }

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
      i.add(STONK_CONFIG.document_name, content)
      i.commit("init")
      repo
    end

    def gen_path(name)
      "#{STONK_CONFIG.bare_repos_path}/#{name.strip}.git"
    end
  end

  def bare_repository
    if @bare_repo.nil?
      @bare_repo = Git.bare path
    end
    @bare_repo
  end

  def bare_content(branch='master')
    @bare_content ||= bare_repository.gtree(branch).blobs[STONK_CONFIG.document_name].contents
  end

  def update_content(content, commit_message, branch='master')
    # clone the repository to a temporary repo
    dirname = "#{STONK_CONFIG.working_copies_path}/#{Digest::MD5.hexdigest rand.to_s}"
    cloned = Git.clone path, dirname
    cloned.checkout branch
    File.open "#{dirname}/#{STONK_CONFIG.document_name}", "w" do |f|
      f.write content
    end
    cloned.commit_all commit_message
    cloned.push
    `rm -rf #{dirname}`
  end
end
