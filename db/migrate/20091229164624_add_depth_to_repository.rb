class AddDepthToRepository < ActiveRecord::Migration
  def self.up
    add_column :repositories, :depth, :integer
    Document.all.each do |document|
      document.repository_tree.each do |node|
        node.repository.depth = node.depth
        node.repository.save!
      end
    end
  end

  def self.down
    remove_column :repositories, :depth
  end
end
