# encoding: utf-8

module FromFile

  module ClassMethods
    def from_file(path)
      new.tap do |obj|
        obj.from_file(path)
      end
    end
  end

  def from_file(path)
    if File.exists?(path) && File.readable?(path)
      self.instance_eval(IO.read(path), path, 1)
    else
      raise IOError, "Cannot open or read #{path}!"
    end
  end

  def self.included(receiver)
    receiver.extend(ClassMethods)
  end

end
