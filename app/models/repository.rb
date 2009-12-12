# == Schema Information
#
# Table name: repositories
#
#  id         :integer(4)      not null, primary key
#  name       :string(80)
#  path       :string(256)
#  created_at :datetime
#  updated_at :datetime
#  human_name :string(255)
#  user_id    :string(255)
#

class Repository < ActiveRecord::Base
  validates_presence_of :path
  validates_presence_of :name
  validates_presence_of :human_name
  validates_uniqueness_of :name
  validates_uniqueness_of :human_name

  has_many :branches, :dependent => :destroy
  has_many :cloned_repositories, :dependent => :destroy, :foreign_key => :original_repository_id
  belongs_to :user

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
      @bare_repo = Grit::Repo.new path, :is_bare => true
    end
    @bare_repo
  end

  def bare_content(branch='master')
    if @bare_content.nil?
      gt = bare_repository.tree branch
      blob = gt/STONK_CONFIG.document_name
      @bare_content = blob.data
    end
    @bare_content
  end

  def branches_excluded branch
    ret=[]
    branches.each do |b|
      ret << b unless b.id == branch.id
    end
    ret
  end

  def forget
    @bare_repo = nil
    @bare_content = nil
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
      write_attribute :path, "#{STONK_CONFIG.bare_repos_path}/#{Digest::MD5.hexdigest rand.to_s}.git"
      puts "Path = #{path}"
    end
  end

  def init_repo
    FileUtils.mkdir_p path
    curdir = Dir.pwd
    Dir.chdir path
    system "git init --bare"
    tmpdir = Dir.mktmpdir
    Dir.chdir tmpdir
    system "git clone #{path} AA"
    Dir.chdir "#{tmpdir}/AA"
    system "touch #{STONK_CONFIG.document_name}"
    system "git add ."
    system "git commit -a -m 'init'"
    system "git push origin master"
    Dir.chdir curdir
    FileUtils.rm_rf tmpdir
    Branch.create! do |b|
      b.name = "master"
      b.human_name = "Ersteller-Zweig"
      b.repository = self 
      b.user_id = user_id 
      b.write_access_for = "own"
    end
  end

end

