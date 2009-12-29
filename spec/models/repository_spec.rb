# == Schema Information
#
# Table name: repositories
#
#  id             :integer(4)      not null, primary key
#  name           :string(80)
#  path           :string(256)
#  created_at     :datetime
#  updated_at     :datetime
#  user_id        :string(255)
#  content        :text
#  commit_message :text
#  parent_id      :integer(4)
#  parent_type    :string(255)
#


require File.expand_path(File.dirname(__FILE__)+"/../spec_helper")

describe Repository do

  before :each do
    @test_doc = Document.create! :human_name => "Test Document"
  end

  it "should make a file and delete it after document destroy" do
    document = Document.create! :human_name => "TestCreateAndDelete"
    File.exists?("#{STONK_CONFIG.bare_repos_path}/TestCreateAndDelete/root/#{STONK_CONFIG.document_name}").should be_true
    document.destroy
    File.exists?("#{STONK_CONFIG.bare_repos_path}/TestCreateAndDelete/root").should be_false
  end

  it "should have a second commit when the content changes" do
    repository = @test_doc.root_repository
    repository.content = "This is the new content"
    repository.commit_message = "Updated the content"
    repository.save!
    g = Git.open repository.path
    g.log.size.should == 2
  end

  it "should create a branched repository" do
    repository = @test_doc.root_repository
    new_rep = Repository.create! :parent => repository, :name => "second_test"
    new_rep.should_not be_nil
    repository.git.remotes.size.should == 1
    new_rep.destroy
    repository.git.remotes.size.should == 0
  end

  it "should update the content of a merged child repository" do
    repo = @test_doc.root_repository
    repo.content = "
THIS IS THE CONTENT OF THE FIRST LINE
"
    child = Repository.create! :parent => repo, :name => "Child"
    child.content = "
THIS IS THE CONTENT OF THE FIRST LINE
AND THIS IS THE SECOND LINE
"
    child.save!
    repo.merge_child child
    repo.content.should == "
THIS IS THE CONTENT OF THE FIRST LINE
AND THIS IS THE SECOND LINE
"
  end

  it "should update the content of a merged parent repository" do
    repo = @test_doc.root_repository
    repo.content = "
THIS IS THE CONTENT OF THE FIRST LINE
"
    repo.save!
    child = Repository.create! :parent => repo, :name => "Child"
    repo.content = "
THIS IS THE CONTENT OF THE FIRST LINE
AND THIS IS THE SECOND LINE
"
    repo.save!
    child.content.should == "
THIS IS THE CONTENT OF THE FIRST LINE
"
    child.merge_parent
    child.content.should == "
THIS IS THE CONTENT OF THE FIRST LINE
AND THIS IS THE SECOND LINE
"
  end

  after :each do
    @test_doc.destroy
  end
end
