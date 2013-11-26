begin
  require 'rspec'
  require 'rspec/core/rake_task'

  desc "Run the specs"
  RSpec::Core::RakeTask.new do |t|
    t.verbose = false
    t.rspec_opts = [
      '--color',
      '--require', 'spec_helper',
      '--format', 'documentation'
    ]
  end

  task :default => [:spec]
rescue LoadError
end
