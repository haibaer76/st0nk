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

require 'test_helper'

class BranchTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
