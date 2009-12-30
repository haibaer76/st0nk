class MyWikiGenerator < MediaWikiHTMLGenerator

  protected

  def parse_wiki_ast ast
    anchorIndex = 0
    sections = []
    arr = ast.children.map do |c|
      case c.class.name
      when FormattedAST.name
        r = parse_formatted c
      when TextAST.name
        r = parse_text c
      when ListAST.name
        r = parse_list c
      when PreformattedAST.name
        r = parse_preformatted c
      when SectionAST.name
        r = parse_section c, anchorIndex
        sections << c
        anchorIndex = anchorIndex+1
      when ParagraphAST.name
        r = parse_paragraph c
      when LinkAST.name
        r = parse_link c
      when InternalLinkAST.name
        r = parse_internal_link c
      when TableAST.name
        r = parse_table c
      when TableRowAST.name
        r = parse_table_row c
      when TableCellAST.name
        r = parse_table_cell c
      end
      r
    end
    links = ''
    sections.each_with_index do |section, index|
      links << "<a href='#kapAnchor#{index}'>#{'&nbsp;'*section.level*2}#{parse_wiki_ast section}</a><br/>"
    end
    links + arr.join
  end

  def parse_section ast, anchorIndex
    "<a name='kapAnchor#{anchorIndex}'/>"+super(ast)
  end
end
