# == Schema Information
#
# Table name: documents
#
#  id         :integer(4)      not null, primary key
#  human_name :string(255)
#  name       :string(255)
#  user_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class Document < ActiveRecord::Base

  belongs_to :user
  has_one :root_repository, :as => :parent, :dependent => :delete, :class_name => Repository.name
  has_one :forum_post, :as => :parent

  validates_presence_of :name
  validates_presence_of :human_name

  validates_uniqueness_of :name
  validates_uniqueness_of :human_name
  
  before_validation :make_name_from_human_name
  after_create :create_master_repository
  before_destroy :delete_path
  
  named_scope :by_name, lambda{|name|
    {:conditions => {:name => name}}
  }

  def get_repository repo_name
    Repository.scoped(:conditions => {:path => "#{path}/#{repo_name}"}).first
  end

  def repository_names
    Dir.entries(path).find_all{|entry| entry!='.' && entry!='..'}
  end

  def repository_tree
    get_repository_tree root_repository
  end

  def path
    STONK_CONFIG.bare_repos_path+"/"+name
  end
  
  protected

  def get_repository_tree current_repo
    ret = []
    ret << current_repo
    current_repo.childs.each do |c|
      ret += get_repository_tree c
    end
    ret
  end

  def create_master_repository
    FileUtils.mkdir_p path
    Repository.create! do |r|
      r.name = 'root'
      r.parent = self
    end
  end

  def make_name_from_human_name
    return unless name.blank?
    index = 0
    suffix = ''
    tst_name = human_name.gsub /[^a-zA-Z0-9_\-]/, '_'
    while not Document.by_name(tst_name+suffix).first.nil?
      index = index+1
      suffix = "_#{index}"
    end
    write_attribute :name, tst_name+suffix
  end

  def delete_path
    FileUtils.rm_rf path unless path.blank?
  end
end
