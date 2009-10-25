# == Schema Information
#
# Table name: repositories
#
#  id         :integer         not null, primary key
#  name       :string(80)
#  path       :string(256)
#  created_at :datetime
#  updated_at :datetime
#

class Repository < ActiveRecord::Base
  validates_presence_of :path
  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :branches, :dependent => :destroy

  named_scope :by_name, lambda{|name|
    {:conditions => {:name => name}}
  }

  class << self
    def new_document(name, user, options={})
      content = options.delete(:content) || "A New Document"
      repo = create!(options[:repository_attributes] || {}) do |r|
        r.name = name
        r.path = gen_path(name)
      end
      Branch.create!(options[:branch_attributes] || {}) do |b|
        b.repository = repo
        b.user = user
        b.name = 'master'
        b.write_access_for = 'own'
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

  def clone_for_edit
    ClonedRepository.create! :original_repository => self
  end

  def branches_excluded branch
    ret=[]
    branches.each do |b|
      ret << b unless b.id == branch.id
    end
    ret
  end

  def before_destroy
    FileUtils.rm_rf path
  end
end

