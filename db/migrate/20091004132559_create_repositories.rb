class CreateRepositories < ActiveRecord::Migration
  def self.up
    create_table :repositories do |t|
      t.string :name, :limit => 80
      t.string :path, :limit => 256
      t.timestamps
    end
  end

  def self.down
    drop_table :repositories
  end
end
