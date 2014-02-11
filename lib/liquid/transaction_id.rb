class TransactionId

  @@current = nil

  def self.current
    @@current
  end

  def self.next(seed = 10000)
    @@current = "#{Time.now.to_i}-#{Process.pid}-#{rand(89999) + seed}"
  end

end
