class AddCopyFromBranchIdToBranch < ActiveRecord::Migration
  def self.up
    add_column :branches, :copy_from_branch_id, :integer
  end

  def self.down
    remove_column :branches, :copy_from_branch_id
  end
end
