# == Schema Information
#
# Table name: repositories
#
#  id         :integer         not null, primary key
#  name       :string(80)
#  path       :string(256)
#  created_at :datetime
#  updated_at :datetime
#  human_name :string(255)
#

require 'test_helper'

class RepositoryTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
