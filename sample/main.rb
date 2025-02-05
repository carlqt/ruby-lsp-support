# frozen_string_literal: true

require 'bundler/setup'
require_relative 'foo'
require_relative 'bar'

Bundler.require(:default)

fifi = Foo.new

fifi.greet
