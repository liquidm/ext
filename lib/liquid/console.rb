require 'erubis'
require 'mixlib/cli'
require 'rib/runner'
require 'rib/all'

module Liquid
  class Console

    def run
      self.__send__(ARGV.shift, *ARGV)
    end

    def console(*args)
      require 'liquid/boot'
      Rib::Runner.run(args)
    end

    def project(name)
      if File.exist?(name)
        puts "!!! #{name} already exists"
        exit(1)
      end

      puts ">>> Generating new project #{name}"

      constant_name = name.split('_').map{|p| p[0..0].upcase + p[1..-1] }.join
      constant_name = constant_name.split('-').map{|q| q[0..0].upcase + q[1..-1] }.join('::') if constant_name =~ /-/
      constant_array = constant_name.split('::')

      config = opts
      config.merge!({
        name: name,
        constant_name: constant_name,
        constant_array: constant_array,
      })

      {
        "Gemfile"                        => "Gemfile",
        "Rakefile"                       => "Rakefile",
        "LICENSE.txt"                    => "LICENSE.txt",
        "README.md"                      => "README.md",
        ".gitignore"                     => "gitignore",
        "#{name}.gemspec"                => "gemspec",
        "bin/#{name}"                    => "binwrapper",
        "config.yml"                     => "config.yml",
        "#{name}/server.rb"              => "server.rb",
      }.each do |dest, source|
        puts "  * #{dest}"
        source = File.join(ROOT, 'lib/liquid/templates', "#{source}.tt")
        dest = File.join(name, dest)
        FileUtils.mkdir_p(File.dirname(dest))
        input = File.read(source)
        eruby = Erubis::Eruby.new(input)
        output = File.open(dest, "w")
        output.write(eruby.result(binding()))
        output.close
      end

      Dir.chdir(name) do
        puts ">>> Installing dependencies"
        system("bundle install")
        system("chmod +x bin/*")
      end
    end
  end
end
