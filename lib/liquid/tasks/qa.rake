def qa_glob
  files = case (ENV['MODE'] || '').to_sym
  when :full
    ['*.rb']
  when :feat
    %x(git diff HEAD..master --name-only).split("\n")
  else
    %x(git diff --name-only).split("\n")
  end

  valid_files = files.map(&:chomp).select{ |file| file =~ /\.rb\z/ }

  if valid_files.any?
    "**/{#{valid_files.join(",")}}"
  end
end

begin
  require 'cane/rake_task'

  namespace :qa do
    Cane::RakeTask.new(:cane) do |cane|
      cane.abc_max = 20
      cane.abc_glob = qa_glob
      cane.add_threshold 'coverage/covered_percent', :>=, 75
      cane.no_style = true
      cane.no_doc = true
    end
  end

rescue LoadError
  warn 'cane not available, QA task not provided.'
end

begin
  require 'reek/rake/task'

  namespace :qa do
    Reek::Rake::Task.new do |t|
      t.fail_on_error = false
      t.source_files = qa_glob
    end
  end

rescue LoadError
  warn 'reek not available, QA task not provided.'
end

begin
  require 'tailor/rake_task'

  namespace :qa do
    Tailor::RakeTask.new do |task|
      task.file_set qa_glob do |style|
        style.max_line_length 0, level: :off
      end
    end
  end

rescue LoadError
  warn 'tailor not available, QA task not provided.'
end

begin
  require 'rubocop/rake_task'

  namespace :qa do
    Rubocop::RakeTask.new(:rubocop) do |task|
      task.patterns = [qa_glob]
      task.formatters = ['fuubar']
      task.fail_on_error = false
    end
  end

rescue LoadError
  warn 'rubocop not available, QA task not provided.'
end

begin
  require 'rails_best_practices'

  namespace :qa do
    desc 'Run rails_best_practices'
    task :rails_best_practices do
      `rails_best_practices #{qa_glob}`
    end
  end

rescue LoadError
  warn 'rails_best_practices not available, QA task not provided.'
end

desc 'Run all QA tasks'
task :qa do
  Rake.application.in_namespace(:qa) do |namespace|
    namespace.tasks.each do |task|
      puts "\033[34m*** Runing #{task.name}\033[0m\n\n"
      task.invoke
    end
  end
end
