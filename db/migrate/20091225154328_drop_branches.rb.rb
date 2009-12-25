class DropBranches < ActiveRecord::Migration
  def self.up
    drop_table :branches
    drop_table :cloned_repositories
  end

  def self.down
  end
end
