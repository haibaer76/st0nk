# == Schema Information
#
# Table name: cloned_repositories
#
#  id                     :integer(4)      not null, primary key
#  path                   :string(255)
#  original_repository_id :integer(4)
#  created_at             :datetime
#  updated_at             :datetime
#  current_branch_name    :string(255)
#

class ClonedRepository < ActiveRecord::Base
  belongs_to :original_repository, :class_name => Repository.name

  validates_presence_of :path
  validates_presence_of :current_branch_name
  validates_uniqueness_of :path

  before_validation :build_path, :check_current_branch_name
  before_destroy :remove_cloned_repository

  def git_repo
    @git_repo ||= Grit::Repo.new path
  end

  def update_content content, message
    cwd = Dir.pwd
    Dir.chdir path
    File.open "#{path}/#{STONK_CONFIG.document_name}", "w" do |f|
      f.write content
    end
    git_repo.commit_all message
    Dir.chdir cwd
  end
  
  protected

  def build_path
    FileUtils.mkdir_p STONK_CONFIG.working_copies_path unless File.exists? STONK_CONFIG.working_copies_path
    if path.nil?
      pathname = Digest::MD5.hexdigest rand.to_s
      write_attribute :path, "#{STONK_CONFIG.working_copies_path}/#{pathname}"
      curdir = Dir.pwd
      Dir.chdir STONK_CONFIG.working_copies_path
      system("git clone #{original_repository.path} #{pathname}")
      Dir.chdir "#{STONK_CONFIG.working_copies_path}/#{pathname}"
      system("git checkout origin/master -b master")
      Dir.chdir curdir
    end
  end

  def check_current_branch_name
    if current_branch_name.nil?
      write_attribute :current_branch_name, "master"
    end
  end

  def remove_cloned_repository
    FileUtils.rm_rf path unless path.nil? || path.blank?
  end

end
