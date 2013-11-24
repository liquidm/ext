# encoding: utf-8

require 'liquid/router'
require 'terminal-table'

desc "Show all ed routes"
task :routes do
  root = File.expand_path(File.dirname(__FILE__))
  router = Router.new(lambda{})
  router.from_file(File.join(root, "../../../config/routes.rb"))
  routes = router.routes.map {|r| [r[0].inspect, r[1], r[2] ] }
  puts Terminal::Table.new({
    rows: routes.sort_by { |route| route[0] },
    headings: ['regex', 'handler', 'parameters'],
  })
end

