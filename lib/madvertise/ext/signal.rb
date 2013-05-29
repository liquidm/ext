module Signal
  def self.register_shutdown_handler(&block)
    at_exit(&block)
    %w(QUIT INT TERM).each do |sig|
      trap(sig) { exit(-1) }
    end
  end
end
