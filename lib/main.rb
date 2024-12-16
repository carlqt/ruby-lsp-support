# frozen_string_literal: true

require 'bundler/setup'
require_relative 'foo'
require_relative 'bar'

Bundler.require(:default)

def walk(node, indent = 0)
  puts "#{' ' * indent}#{node.type}"
  node.compact_child_nodes.each { |child| walk(child, indent + 2) }
end

f = File.read('lib/foo.rb')

parsed_file = Prism.parse(f)
node = parsed_file.value

puts 'Done parsing'
