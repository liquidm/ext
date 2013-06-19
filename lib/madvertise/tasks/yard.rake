begin
  require 'yard'

  YARD::Rake::YardocTask.new do |t|
    t.files = ['lib/**/*.rb', 'README.rdoc']
  end
rescue LoadError
end
