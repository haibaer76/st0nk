class RefacRepositories < ActiveRecord::Migration
  def self.up
    remove_column :repositories, :parent_repository_id
    remove_column :repositories, :document_id
    add_column :repositories, :parent_id, :integer
    add_column :repositories, :parent_type, :string
  end

  def self.down
    raise "This migration cannot be reverted."
  end
end
