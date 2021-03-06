# == Schema Information
#
# Table name: repositories
#
#  id             :integer(4)      not null, primary key
#  name           :string(80)
#  path           :string(256)
#  created_at     :datetime
#  updated_at     :datetime
#  user_id        :string(255)
#  content        :text
#  commit_message :text
#  parent_id      :integer(4)
#  parent_type    :string(255)
#

class Repository < ActiveRecord::Base
  attr_protected :user_id, :created_at, :updated_at, :user_id, :parent_id, :parent_type
  attr_readonly :name, :path
  validates_presence_of :path
  validates_presence_of :name
  validates_presence_of :document
  validates_inclusion_of :can_changed_by, :in => %w( all owner )

  belongs_to :user
  belongs_to :parent, :polymorphic => true
  has_many :childs, :class_name => Repository.name, :as => :parent

  before_validation :sanitize_name_and_make_path
  before_validation_on_create :copy_content_from_parent
  before_validation_on_create :set_depth
  before_validation_on_create :set_can_changed_by_to_all
  before_validation_on_create :copy_user_id_from_document
  validate_on_create :check_path_not_exists

  after_create :make_repository
  before_update :commit_new_content
  before_destroy :delete_repository

  def git
    @git ||= Git.open path
  end

  def write_access_for? u
    return true if can_changed_by == 'all'
    return true if user.nil?
    return u.id == user.id
  end

  def document
    return nil if parent.nil?
    return parent if parent.is_a? Document
    parent.document
  end

  def has_commit_after other_repository
    log = git.log
    other_log = other_repository.git.log
    log.first.date > other_log.first.date
  end

  def merge_child child
    if child.is_a? String
      name = child
    elsif child.is_a? Repository
      name = child.name
    elsif child.is_a? Fixnum
      name = Repository.find(child).name
    else
      raise "Do not know how to handle parameter of class #{child.class.name}"
    end
    git.chdir do
      git.fetch name
      begin
        git.merge "#{name}/master"
      rescue Git::GitExecuteError => ex
      end
      write_attribute :content, File.read(STONK_CONFIG.document_name).to_s
    end
    @skip_commit = true
    save!
    @skip_commit = false
  end

  def diff_to child_id
    name = Repository.find(child_id).name
    git.chdir do
      git.fetch name
      git.diff(git.branch('master'), git.branch("#{name}/master"))
    end
  end

  def merge_parent
    return if parent.is_a? Document
    git.chdir do
      git.fetch 'origin'
      begin
        git.merge 'origin/master'
      rescue Git::GitExecuteError => ex
      end
      write_attribute :content, File.read(STONK_CONFIG.document_name).to_s
    end
    @skip_commit = true
    save!
    @skip_commit = false
  end

  protected

  def sanitize_name_and_make_path
    return unless path.blank?
    hlp_name = name.gsub /[^a-zA-Z0-9_\-]/, '_'
    write_attribute :name, hlp_name
    write_attribute :path, "#{STONK_CONFIG.bare_repos_path}/#{document.name}/#{hlp_name}"
  end

  def make_repository
    FileUtils.mkdir_p path
    if parent.is_a? Document
      repo = Git.init path
      repo.chdir do
        File.open(STONK_CONFIG.document_name, 'w') do |f|
          f.write content
        end
        repo.add
        repo.commit_all "Init"
      end
    else
      repo = Git.clone parent.git.repo, path, :bare => false
      prepo = parent.git
      prepo.add_remote name, path
      repo.add_remote parent.name, parent.path
    end
  end

  def delete_repository
    FileUtils.rm_rf path
    if parent.is_a? Document
      parent.destroy
    else
      Dir.chdir parent.path do
        system "git remote rm #{name}"
      end
    end
  end

  def commit_new_content
    return if @skip_commit
    return unless content_changed?
    repo = Git.open path
    repo.chdir do
      File.open(STONK_CONFIG.document_name, 'w') do |f|
        f.write content
      end
      repo.commit_all(commit_message.blank? ? "Changed on #{Time.now.to_s}" : commit_message)
    end
  end

  def check_path_not_exists
    if File.exists? path
      errors.add :name, "has been already taken"
    end
  end

  def copy_content_from_parent
    return if parent.is_a? Document
    write_attribute :content, parent.content
  end

  def set_depth
    d = parent.is_a?(Document)?0:parent.depth+1
    write_attribute :depth, d
  end

  def set_can_changed_by_to_all
    return unless can_changed_by.nil?
    write_attribute :can_changed_by, 'all'
  end

  def copy_user_id_from_document
    return unless user.nil?
    return unless parent.is_a? Document
    write_attribute :user_id, parent.user_id
  end
end

