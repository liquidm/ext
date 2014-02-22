require_relative "./jeromq-0.3.3.jar"
java_import "org.zeromq.ZContext"
java_import "org.zeromq.ZFrame"
java_import "org.zeromq.ZLoop"
java_import "org.zeromq.ZMQ"
java_import "org.zeromq.ZMQException"
java_import "org.zeromq.ZMQQueue"
java_import "org.zeromq.ZMsg"
java_import "org.zeromq.ZThread"
java_import "java.nio.channels.ClosedSelectorException"

class ZContext
  def create_socket_with_opts(type, opts = {})
    socket = create_socket(type)
    opts.each do |key, value|
      next if key == :bind || key == :connect
      socket.__send__("#{key}=", value)
    end
    socket.connect(opts[:connect]) if opts[:connect]
    socket.bind(opts[:bind]) if opts[:bind]
    socket
  end

  def router(opts = {})
    create_socket_with_opts(ZMQ::ROUTER, opts)
  end

  def dealer(opts = {})
    create_socket_with_opts(ZMQ::DEALER, opts)
  end

  def push(opts = {})
    create_socket_with_opts(ZMQ::PUSH, opts)
  end

  def pull(opts = {})
    create_socket_with_opts(ZMQ::PULL, opts)
  end

  def pub(opts = {})
    create_socket_with_opts(ZMQ::PUB, opts)
  end

  def sub(opts = {})
    create_socket_with_opts(ZMQ::SUB, opts)
  end

  ## global context instance

  def self.instance
    @context ||= new
  end

  def self.create_socket(type)
    instance.create_socket(type)
  end

  def self.destroy_socket(socket)
    instance.destroy_socket(socket)
  end

  def self.destroy
    instance.destroy
  end

  def self.router(opts = {})
    instance.router(opts)
  end

  def self.dealer(opts = {})
    instance.dealer(opts)
  end

  def self.push(opts = {})
    instance.push(opts)
  end

  def self.pull(opts = {})
    instance.pull(opts)
  end

  def self.pub(opts = {})
    instance.pub(opts)
  end

  def self.sub(opts = {})
    instance.sub(opts)
  end
end
