class String
  alias each each_line

  def clean_quote
    if index(/["\s]/)
      %{"#{tr('"', "'")}"}
    else
      self
    end
  end
end
