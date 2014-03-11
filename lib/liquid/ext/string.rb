class String
  alias each each_line

  def clean_quote
    if index(/["\s]/)
      %{"#{tr('"', "'")}"}
    else
      self
    end
  end

  # from: http://rubydoc.info/gems/extlib/0.9.15/String#camel_case-instance_method
  def camel_case
    return self if self !~ /_/ && self =~ /[A-Z]+.*/
    split('_').map{|e| e.capitalize}.join
  end

  def snake_case
    return downcase if match(/\A[A-Z]+\z/)
    gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
        gsub(/([a-z])([A-Z])/, '\1_\2').
        downcase
  end
end
