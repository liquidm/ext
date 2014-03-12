class Socket
  def self.ipaddress
    hostname = %x(hostname).chomp
    getaddrinfo(hostname, nil).first[3]
  end

  def self.fqdn
    Socket.gethostbyaddr(IPAddr.new(ipaddress).hton)[0]
  end
end
