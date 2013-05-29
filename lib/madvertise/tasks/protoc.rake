desc "build all protocol buffer schemas"
task :protoc do
  Dir["**/*.proto"].each do |file|
    sh "ruby-protoc #{file}"
  end
end
