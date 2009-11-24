class AddHumanNameToRepository < ActiveRecord::Migration
  def self.up
    add_column :repositories, :human_name, :string
  end

  def self.down
    remove_column :repositories, :human_name
  end
end
