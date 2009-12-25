require 'test_helper'

class ForumPostTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

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

