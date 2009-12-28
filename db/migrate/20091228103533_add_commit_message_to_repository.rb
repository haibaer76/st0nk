class AddCommitMessageToRepository < ActiveRecord::Migration
  def self.up
    add_column :repositories, :commit_message, :text
  end

  def self.down
    remove_column :repositories, :commit_message
  end
end
