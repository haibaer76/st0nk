require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Branch do
  before :all do
    @repository = Repository.create_with_human_name "Test"
    @branch = Branch.create! :repository => @repository, :name => 'test', :human_name => 'test', :write_access_for => 'public'
  end

  it "should create a new branch when the name is not 'master'" do
    @repository.forget
    repo = @repository.bare_repository
    repo.branches.size.should == 2
    repo.branches.collect{|b| b.name}.sort.should == ["master", "test"]
  end

  after :all do
    @repository.destroy
  end
end
