# == Schema Information
#
# Table name: cloned_repositories
#
#  id                     :integer(4)      not null, primary key
#  path                   :string(255)
#  original_repository_id :integer(4)
#  created_at             :datetime
#  updated_at             :datetime
#  current_branch_name    :string(255)
#

require 'test_helper'

class ClonedRepositoryTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
