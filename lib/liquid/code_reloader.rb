require 'listen'

class CodeReloader

  def initialize(path)
    $log.debug("code.reloader", active: true, path: path)
    Listen.to(path) do |m, a, r|
      Thread.name = "Code Reloader (#{path})"
      (m + a).uniq.each do |file|
        reload(file)
      end
    end.start
  end

  def reload(file)
    if file =~ /\.rb$/
      $log.info("code.reloader", reload: file)
      begin
        load(file)
      rescue SyntaxError => e
        $log.exception(e)
      rescue => e
        $log.exception(e)
      end
    end
  end

end
