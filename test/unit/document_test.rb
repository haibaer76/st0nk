require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

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

