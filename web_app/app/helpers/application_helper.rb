module ApplicationHelper
  def pluralize(count, one, few, many)
    case count % 100
    when 11..14
      many
    else
      case count % 10
      when 1
        one
      when 2..4
        few
      else
        many
      end
    end
  end
end
