require_relative 'foo'

class Bar < Foo
  class BarInstance < superclass::FooInstance

    # In this instance of superclass
    # The value of @node_context.nesting is
    # ["Bar", "BarInstance", "CarInstance"]]

    # The lefthand side is included in the nest
    class CarInstance < superclass::FooInstance
    end
  end
end

# [Bar, BarInstance, CarInstance]
