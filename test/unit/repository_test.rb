require 'test_helper'

class RepositoryTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

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

