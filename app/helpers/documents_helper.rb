module DocumentsHelper
  def wiki_parse_content content
    parser = MediaWikiParser.new
    parser.lexer = MediaWikiLexer.new
    ast = parser.parse(content || " ")
    walker = MyWikiGenerator.new
    walker.parse ast
    walker.html
  end
end
