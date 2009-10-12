class AddDescriptionToBranch < ActiveRecord::Migration
  def self.up
    add_column :branches, :description, :string
  end

  def self.down
    remove_column :branches, :description
  end
end
