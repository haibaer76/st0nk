require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ClonedRepository do
  before :all do
    @repository = Repository.create_with_human_name "Test"
  end

  describe "creates and makes path for repository name" do
    before :all do
      @clone = ClonedRepository.create! :original_repository => @repository
    end

    it "Should have attributes" do
      @clone.should_not be_nil
      @clone.path.match(/^#{STONK_CONFIG.working_copies_path}\/[0-9a-f]{32}$/).should_not be_nil
    end

    it "Should has directory and files" do
      File.exists?(@clone.path).should be_true
      File.exists?("#{@clone.path}/.git").should be_true
      File.exists?("#{@clone.path}/#{STONK_CONFIG.document_name}").should be_true
    end

    after :all do
      @clone.destroy
    end
  end

  describe "Removing directory" do
    it "should remove directory after destroy" do
      clone = ClonedRepository.create! :original_repository => @repository
      p = clone.path
      clone.destroy
      File.exists?(p).should be_false
    end
  end

  describe "Instance methods" do
    before :all do
      @clone = ClonedRepository.create! :original_repository => @repository
    end

    it "should get the git repository of the clone" do
      @clone.git_repo.should_not be_nil
    end

    after :all do
      @clone.destroy
    end
  end
  after :all do
    @repository.destroy
  end
end
