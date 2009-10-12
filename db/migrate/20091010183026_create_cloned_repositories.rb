class CreateClonedRepositories < ActiveRecord::Migration
  def self.up
    create_table :cloned_repositories do |t|
      t.string :path
      t.integer :original_repository_id
      t.timestamps
    end
  end

  def self.down
    drop_table :cloned_repositories
  end
end
