require 'listen'

class CodeReloader

  def initialize
    $log.info("code.reloader", active: true, path: Dir.pwd)
    Listen.to(Dir.pwd) do |m, a, r|
      Thread.name = "Code Reloader"
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
      # rescue TypeError => e
      #   # hacky hacky
      #   if klass = e.message[/superclass mismatch for class (\w+)/,1]
      #     send(:remove_const, klass)
      #     reload(file)
      #   end
      rescue => e
        $log.exception(e)
      end
    end
  end

end

