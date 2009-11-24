# == Schema Information
#
# Table name: cloned_repositories
#
#  id                     :integer         not null, primary key
#  path                   :string(255)
#  original_repository_id :integer
#  created_at             :datetime
#  updated_at             :datetime
#

class ClonedRepository < ActiveRecord::Base
  belongs_to :original_repository, :class_name => Repository.name

  validates_presence_of :path
  validates_uniqueness_of :path

  before_validation :build_path
  before_destroy :remove_cloned_repository

  def git_repo
    @git_repo ||= Git.open path
  end

  protected

  def build_path
    if path.nil?
      self.path="#{STONK_CONFIG.working_copies_path}/#{Digest::MD5.hexdigest rand.to_s}"
      Git.clone original_repository.path, path
    end
  end

  def remove_cloned_repository
    FileUtils.rm_rf path unless path.nil? || path.blank?
  end
end
