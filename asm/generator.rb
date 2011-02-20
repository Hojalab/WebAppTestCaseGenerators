#!/usr/bin/env ruby
require 'parser.rb'
require 'find'

unless ARGV.length == 1
  printf("Usage: %s path_to_rails_app_root\n", $0)
  exit
end

rails_root_path = ARGV.first
app_path = File.join(rails_root_path, 'app')
unless File.exists?(app_path)
  printf("ERROR: expected app directory does not exist at %s", app_path)
  exit
end

views_path = File.join(app_path, 'views')
unless File.exists?(views_path)
  printf("ERROR: expected app/views directory does not exist at %s", views_path)
  exit
end

ERB_FILE_TYPES = ['rhtml', 'erb'].freeze
EXCLUDED_DIRS = ['.svn'].freeze
paths_comp_exprs = {}

Find.find(views_path) do |path|
  if FileTest.directory?(path)
    dir_name = File.basename(path.downcase)
    if EXCLUDED_DIRS.include?(dir_name)
      Find.prune # Don't look in this directory
    else
      printf("Looking in directory %s\n", path)
    end
  else # Found a file
    file_type = File.basename(path.downcase).split('.').last
    if ERB_FILE_TYPES.include?(file_type)
      erb = IO.readlines(path).join
      ast = Parser.new.parse(erb, path)
      expr = ast.component_expression()
      paths_comp_exprs[path] = expr
    end
  end
end

puts "Component expressions:"
paths_comp_exprs.each do |path, expr|
  printf("%s =>\n\t%s\n\n", path, expr)
end
