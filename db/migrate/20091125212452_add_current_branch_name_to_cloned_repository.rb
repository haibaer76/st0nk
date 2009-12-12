class AddCurrentBranchNameToClonedRepository < ActiveRecord::Migration
  def self.up
    add_column :cloned_repositories, :current_branch_name, :string
  end

  def self.down
    remove_column :cloned_repositories, :current_branch_name
  end
end
