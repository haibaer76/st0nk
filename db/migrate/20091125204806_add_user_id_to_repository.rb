class AddUserIdToRepository < ActiveRecord::Migration
  def self.up
    add_column :repositories, :user_id, :string
  end

  def self.down
    remove_column :repositories, :user_id
  end
end
