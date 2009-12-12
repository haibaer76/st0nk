class AddHumanNameToBranch < ActiveRecord::Migration
  def self.up
    add_column :branches, :human_name, :string
  end

  def self.down
    remove_column :branches, :human_name
  end
end
