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

  before :all do
    @document = Document.create! :human_name => "A Simple Test"
  end

  it "should create a repository together with the document" do
    @document.repositories.size.should == 1
  end

  it 'should make a name without spaces' do
    @document.name.should == "A_Simple_Test"
  end

  it 'should count up the index when document is created with the same name' do
    doc2 = Document.create! :human_name => "A_Simple Test"
    doc2.name.should == "A_Simple_Test_1"
    doc2.destroy
  end

  after :all do
    @document.destroy
  end
end
