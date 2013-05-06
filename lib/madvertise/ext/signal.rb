module Signal
  def self.register_shutdown_handler(&block)
    %w(QUIT INT TERM).each do |sig|
      old = trap(sig) {}
      trap(sig) { block.call; old.call }
    end
  end
end
