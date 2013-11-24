# make default what should be default
Thread.abort_on_exception = true

class Thread

  def self.name
    Thread.current[:name] || Java::JavaLang::Thread.currentThread.getName
  end

  def self.name=(value)
    Thread.current[:name] = value
    if RUBY_PLATFORM == "java"
      Java::JavaLang::Thread.currentThread.setName(value)
    end
  end

end
