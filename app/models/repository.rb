# == Schema Information
#
# Table name: repositories
#
#  id                   :integer(4)      not null, primary key
#  name                 :string(80)
#  path                 :string(256)
#  created_at           :datetime
#  updated_at           :datetime
#  user_id              :string(255)
#  document_id          :integer(4)
#  parent_repository_id :integer(4)
#

class Repository < ActiveRecord::Base
  validates_presence_of :path
  validates_presence_of :name
  validates_presence_of :document

  belongs_to :user
  belongs_to :document, :class_name => Document.name, :foreign_key => :document_id
  belongs_to :parent_repository, :class_name => Repository.name, :foreign_key => :parent_repository_id
  has_many :remote_clones, :class_name => Repository.name, :foreign_key => :parent_repository_id

  before_validation :sanitize_name_and_make_path

  validates_uniqueness_of :name, :scope => :document_id

  protected

  def sanitize_name_and_make_path
    return unless path.blank?
    hlp_name = name.gsub /[^a-zA-Z0-9_\-]/, '_'
    write_attribute :path, "#{STONK_CONFIG.bare_repos_path}/#{document.name}/#{hlp_name}.git"
  end
end
