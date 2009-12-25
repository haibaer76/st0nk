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
  has_many :repositories, :dependent => :destroy, :foreign_key => :document_id
  has_one :forum_post, :as => :parent

  validates_presence_of :name
  validates_presence_of :human_name

  validates_uniqueness_of :name
  validates_uniqueness_of :human_name
  
  before_validation :make_name_from_human_name
  after_create :create_master_repository
  
  named_scope :by_name, lambda{|name|
    {:conditions => {:name => name}}
  }

  protected

  def create_master_repository
    Repository.create! do |r|
      r.name = 'main'
      r.document = self
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
end
