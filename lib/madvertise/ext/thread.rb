class Thread
  def name=(value)
    self[:name] = value
    if RUBY_PLATFORM == "java"
      java.lang.Thread.currentThread.setName(value)
    end
  end
end
