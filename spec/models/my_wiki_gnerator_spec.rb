require File.expand_path(File.dirname(__FILE__)+"/../spec_helper")

describe MyWikiGenerator do
  before :each do
    @test_text = "
=SECTION 1=
Some text for the paragraph
"
    parser = MediaWikiParser.new
    parser.lexer = MediaWikiLexer.new
    @ast = parser.parse @test_text
  end

  it "should get the correct parsed content" do
    walker = MyWikiGenerator.new
    walker.parse @ast
    result = walker.html
    /<a href='#kapAnchor0'/.match(result).should_not be_nil
    /<a name='kapAnchor0'/.match(result).should_not be_nil
    /<h1>SECTION 1/.match(result).should_not be_nil
  end
end
