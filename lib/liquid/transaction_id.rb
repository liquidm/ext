class TransactionId

  @@current = nil

  def self.current
    @@current
  end

  def self.next
    @@current = "#{Time.now.to_i}-#{Process.pid}-#{rand(89999) + 10000}"
  end

end
