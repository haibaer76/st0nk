# == Schema Information
#
# Table name: repositories
#
#  id         :integer         not null, primary key
#  name       :string(80)
#  path       :string(256)
#  created_at :datetime
#  updated_at :datetime
#  human_name :string(255)
#

class Repository < ActiveRecord::Base
  validates_presence_of :path
  validates_presence_of :name
  validates_presence_of :human_name
  validates_uniqueness_of :name
  validates_uniqueness_of :human_name

  has_many :branches, :dependent => :destroy

  after_create :init_repo
  before_destroy :remove_repo
  before_validation :make_name_and_path

  named_scope :by_name, lambda{|name|
    {:conditions => {:name => name}}
  }

  def self.create_with_human_name human_name
    self.create! :human_name => human_name
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

  def branches_excluded branch
    ret=[]
    branches.each do |b|
      ret << b unless b.id == branch.id
    end
    ret
  end

  protected

  def remove_repo
    FileUtils.rm_rf path
  end

  def make_name_and_path
    if name.nil? 
      tst_name = human_name.gsub /[^a-zA-Z0-9]/, '_'
      index=''
      count=0
      while not Repository.by_name("#{tst_name}#{index}").empty?
        count = count+1
        index = "_#{count}"
      end
      write_attribute :name, "#{tst_name}#{index}"
    end
    if path.nil?
      write_attribute :path, "#{STONK_CONFIG.bare_repos_path}/#{name}.git"
    end
  end

  def init_repo
    @bare_repository = Grit::Repo.init_bare path
    i = @bare_repository.index
    i.add(STONK_CONFIG.document_name, '')
    i.commit("init")
  end
end

