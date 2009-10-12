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

require 'test_helper'

class ClonedRepositoryTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
