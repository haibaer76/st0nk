class CreateBranches < ActiveRecord::Migration
  def self.up
    create_table :branches do |t|
      t.string :name
      t.string :write_access_for
      t.references :repository
      t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :branches
  end
end
