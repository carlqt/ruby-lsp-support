# frozen_string_literal: true

class Abc
  def age
    2
  end
end

# def define_handler_for
#   yield
# end

define_handle_for do |event|
  ax = Abc.new
end
