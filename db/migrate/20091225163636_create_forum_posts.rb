class CreateForumPosts < ActiveRecord::Migration
  def self.up
    create_table :forum_posts do |t|
      t.references :user
      t.references :parent, :polymorphic => true
      t.text :content
      t.timestamps
    end
  end

  def self.down
    drop_table :forum_posts
  end
end
