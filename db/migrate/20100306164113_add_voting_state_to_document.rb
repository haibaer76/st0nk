class AddVotingStateToDocument < ActiveRecord::Migration
  def self.up
    add_column :documents, :voting_state, :string, :default => 'brainstorm'
  end

  def self.down
    remove_column :documents, :voting_state
  end
end
