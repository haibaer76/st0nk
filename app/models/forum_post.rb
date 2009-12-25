# == Schema Information
#
# Table name: forum_posts
#
#  id          :integer(4)      not null, primary key
#  user_id     :integer(4)
#  parent_id   :integer(4)
#  parent_type :string(255)
#  content     :text
#  created_at  :datetime
#  updated_at  :datetime
#

class ForumPost < ActiveRecord::Base
  belongs_to :parent, :polymorphic => true
  belongs_to :user

  has_many :child_posts, :class_name => ForumPost.name, :as => :parent
  validates_presence_of :parent
end
