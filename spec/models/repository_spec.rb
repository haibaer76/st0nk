# == Schema Information
#
# Table name: repositories
#
#  id         :integer         not null, primary key
#  name       :string(80)
#  path       :string(256)
#  created_at :datetime
#  updated_at :datetime
#  human_name :string(255)
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Repository do

  describe "creates and makes name and path from human name" do

    before :all do
      @repo = Repository.create! :human_name => "A Repository for testing"
    end

    it "should make a real name" do
      @repo.name.should == "A_Repository_for_testing"
      @repo.path.should == "#{STONK_CONFIG.bare_repos_path}/A_Repository_for_testing.git"
    end

    it "should create one repository" do
      @repo.should_not be_nil
      File.exist?(@repo.path).should be_true
      File.directory?(@repo.path).should be_true
      File.exist?("#{@repo.path}/config").should be_true
    end

    after :all do
      @repo.destroy
    end
  end

  describe "Bare repository is deleted after destroy" do
    it "should be deleted" do
      repo = Repository.create! :human_name => "Test"
      p = repo.path
      repo.destroy
      File.exist?(p).should be_false
    end
  end

  describe "Multiple repositories with same human name" do
    before :each do
      @repo1 = Repository.create! :human_name => "Test+"
      @repo2 = Repository.create! :human_name => "Test-"
    end

    it "should set name properly" do
      @repo1.name.should == "Test_"
      @repo2.name.should == "Test__1"
    end

    after :each do
      @repo1.destroy
      @repo2.destroy
    end
  end

  describe "Repository instance methods do" do
    before :each do
      @repo = Repository.create! :human_name => "Test"
    end

    it "should get the bare repository" do
      @repo.bare_repository.should_not be_nil
    end

    after :each do
      @repo.destroy
    end
  end
end
