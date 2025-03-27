# frozen_string_literal: true

require 'dry-struct'
require_relative 'foo'

module Types
  include Dry.Types
end

class User < Dry::Struct
  attribute :name, Types::String.optional
  attribute :age, Types::Integer
  attribute :greet, Types::String

  # something something
  def john; end
end

class Diego < User
  attribute :pangalan, Types::String
  attribute :xyz, Types::String
end

class Abc
  def age(x = 1)
    2
  end

  def name; end
  def address;end
  def learn;end
end

class Xyz < Abc
  def boy; end
  def girl; end

  def self.build
    @diego = Diego.new
  end
end

define_handle_for(Diego) do |e|
  e.
  a.
end
