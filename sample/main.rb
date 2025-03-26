# frozen_string_literal: true

require 'dry-struct'
require_relative 'foo'

module Types
  include Dry.Types
end

class Abc
  def age(x = 1)
    2
  end
end

class User < Dry::Struct
  attribute :name, Types::String
end

define_handle_for(Foo::FooInstance) do |event|
  event
end
