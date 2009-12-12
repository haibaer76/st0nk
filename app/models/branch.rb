# == Schema Information
#
# Table name: branches
#
#  id               :integer(4)      not null, primary key
#  name             :string(255)
#  write_access_for :string(255)
#  repository_id    :integer(4)
#  user_id          :integer(4)
#  created_at       :datetime
#  updated_at       :datetime
#  description      :string(255)
#

class Branch < ActiveRecord::Base
  belongs_to :repository
  belongs_to :user

  named_scope :by_name, lambda {|name| {
    :conditions => {:name => name}
  }}
  validates_uniqueness_of :name, :scope => :repository_id
  validates_presence_of :human_name
  validates_uniqueness_of :human_name, :scope => :repository_id
  validates_presence_of :write_access_for
  validates_presence_of :repository
  validates_presence_of :name
  validates_inclusion_of :write_access_for, :in => ['public', 'user', 'own', 'vote']
  after_create :do_create_branch

  protected

  def do_create_branch
    return if name == 'master'
    cwd = Dir.pwd
    dirname = "#{STONK_CONFIG.working_copies_path}/#{Digest::MD5.hexdigest rand.to_s}"
    system("git clone #{repository.path} #{dirname}");
    Dir.chdir dirname
    system("git checkout origin/#{other_branch_name} -b #{name}")
    system("git push origin #{name}")
    Dir.chdir cwd
    FileUtils.rm_rf dirname
  end

  def other_branch_name
    return 'master' if copy_from_branch_id.nil?
    Branch.find(copy_from_branch_id).name
  end
end
