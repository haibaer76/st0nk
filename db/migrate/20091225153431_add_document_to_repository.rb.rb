class AddDocumentToRepository < ActiveRecord::Migration
  def self.up
    Repository.all.each do |r|
      r.destroy
    end
    add_column :repositories, :document_id, :integer
    add_column :repositories, :parent_repository_id, :integer
    remove_column :repositories, :human_name
  end

  def self.down
    throw "This Migration cannot be undone."
  end
end
