class AddContentToRepository < ActiveRecord::Migration
  def self.up
    add_column :repositories, :content, :text
  end

  def self.down
    remove_column :repositories, :content
  end
end
