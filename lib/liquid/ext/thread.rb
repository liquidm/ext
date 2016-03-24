# make default what should be default
Thread.abort_on_exception = true

class Thread

  def self.name
    if RUBY_PLATFORM == "java"
      Java::JavaLang::Thread.currentThread.getName
    else
      Thread.current[:name]
    end
  end

  def self.name=(value)
    Thread.current[:name] = value
    if RUBY_PLATFORM == "java"
      Java::JavaLang::Thread.currentThread.setName(value)
    end
  end

  def self.join
    Thread.list.reject do |thread|
      thread == Thread.current
    end.each(&:join)
  end

end
