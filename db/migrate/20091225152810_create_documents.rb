class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.string :human_name
      t.string :name
      t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :documents
  end
end
