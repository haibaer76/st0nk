class DiffLine
  def initialize line
    @line = line
  end

  def as_html
    "<div class='#{line_class}'>#{h @line}</div>"
  end

  def line_class
    case @line[0..0]
    when '+'
      'clsGreenBackground'
    when '-'
      'clsRedBackground'
    else
      'clsDefaultbackground'
    end
  end
end
