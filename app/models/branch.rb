# == Schema Information
#
# Table name: branches
#
#  id               :integer         not null, primary key
#  name             :string(255)
#  write_access_for :string(255)
#  repository_id    :integer
#  user_id          :integer
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
  validates_presence_of :write_access_for
  validates_presence_of :repository
  validates_presence_of :name
  validates_inclusion_of :write_access_for, :in => ['public', 'user', 'own']
  after_create :do_create_branch

  attr_accessor :copy_from_branch_id

  def do_create_branch
    return if name == 'master'
    repo = repository.bare_repository
    repo.branch(other_branch_name).checkout
    repo.branch(name).checkout
  end

  def other_branch_name
    return 'master' if copy_from_branch_id.nil?
    Branch.find(copy_from_branch_id).name
  end
end
