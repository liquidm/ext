require 'ipaddr'

class Socket
  def self.ipaddress
    getaddrinfo(gethostname, nil).first[3]
  end

  def self.fqdn
    gethostbyaddr(IPAddr.new(ipaddress).hton)[0]
  end
end
