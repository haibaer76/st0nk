# == Schema Information
#
# Table name: documents
#
#  id         :integer(4)      not null, primary key
#  human_name :string(255)
#  name       :string(255)
#  user_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Document do

  before :each do
    @document = Document.create! :human_name => "A Simple Test"
  end

  it "should create a root repository with the document" do
    @document.root_repository.should_not be_nil
  end

  it 'should make a name without spaces' do
    @document.name.should == "A_Simple_Test"
  end

  it 'should count up the index when document is created with the same name' do
    doc2 = Document.create! :human_name => "A_Simple Test"
    doc2.name.should == "A_Simple_Test_1"
    doc2.destroy
  end

  it 'should get the repository with the name root' do
    @document.get_repository("root").should_not be_nil
    @document.get_repository('does not exist').should be_nil
  end

  it "should build the document tree correctly" do
    tree = @document.repository_tree
    tree.size.should == 1
    tree.first.depth.should == 0
    tree.first.repository.name.should == "root"
  end

  it "should have the tree of a complex structure correctly" do
    root = @document.root_repository
    c1 = Repository.create! :parent => root, :name => "Child1"
    c2 = Repository.create! :parent => root, :name => "Child2"
    gc = Repository.create! :parent => c1, :name => "GrandChild1"
    tree = @document.repository_tree
    tree.size.should == 4
    tree[0].depth.should == 0
    tree[1].depth.should == 1
    tree[2].depth.should == 2
    tree[3].depth.should == 1
  end

  after :each do
    @document.destroy
  end
end
