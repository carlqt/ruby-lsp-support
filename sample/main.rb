# frozen_string_literal: true

require 'dry-struct'
require_relative 'foo'

module Types
  include Dry.Types
end

class User < Dry::Struct
  attribute :name, Types::String
end

class Abc
  def age(x = 1)
    2
  end

  def name; end
  def address;end
  def learn;end
end

define_handle_for(Abc) do |e|

end
