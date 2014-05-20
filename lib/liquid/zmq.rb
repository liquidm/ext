if RUBY_PLATFORM == "java"
  java_import "org.zeromq.ZContext"
  java_import "org.zeromq.ZFrame"
  java_import "org.zeromq.ZLoop"
  java_import "org.zeromq.ZMQ"
  java_import "org.zeromq.ZMQException"
  java_import "org.zeromq.ZMQQueue"
  java_import "org.zeromq.ZMsg"
  java_import "org.zeromq.ZThread"

  class ZMQ
    class Socket
      # for performance reason we alias the method here (otherwise it uses reflections all the time!)
      # super ugly, since we need to dynamically infer the java class of byte[]
      java_alias :send_byte_buffer, :sendByteBuffer, [Java::JavaNio::ByteBuffer.java_class, Java::int]
      java_alias :send_byte_array, :send, [[].to_java(:byte).java_class, Java::int]
      java_alias :recv_byte_array, :recv, [Java::int]

      def write(buffer)
        bytes = send_byte_buffer(buffer, 0)
        buffer.position(buffer.position + bytes)
      end
    end
  end

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

    @mutex = Mutex.new

    def self.instance
      @mutex.synchronize do
        @context ||= new
      end
    end

    def self.create_socket(type)
      instance.create_socket(type)
    end

    def self.destroy_socket(socket)
      instance.destroy_socket(socket)
    end

    # really incredible how many exceptions a simple shutdown can throw all over
    # the place. if it's one thing ZMQ did never get right it is the shutdown
    # logic ...
    def self.destroy
      instance.destroy
    rescue Java::JavaLang::IllegalStateException, Java::JavaLang::NullPointerException
      # ignore broken shutdown in zeromq
    end

    DestroyExceptions = [
      Java::JavaNioChannels::AsynchronousCloseException,
      Java::JavaNioChannels::ClosedChannelException,
      Java::JavaNioChannels::ClosedSelectorException,
    ]

    Exceptions = DestroyExceptions + [
      Java::OrgZeromq::ZMQException,
      Java::Zmq::ZError::IOException,
    ]

    def self.destroy_exception?(e)
      return true if e.is_a?(Java::OrgZeromq::ZMQException) && ZMQ::Error::ETERM.getCode == e.getErrorCode
      return true if e.is_a?(Java::Zmq::ZError::IOException) && DestroyExceptions.include?(e.cause.class)
      return true if DestroyExceptions.include?(e.class)
      return false
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
end
