class AddCanChangedByToRepository < ActiveRecord::Migration
  def self.up
    add_column :repositories, :can_changed_by, :string
    Repository.all.each do |r|
      next if r.document.nil?
      r.can_changed_by = "all"
      r.save!
    end
  end

  def self.down
    remove_column :repositories, :can_changed_by
  end
end
