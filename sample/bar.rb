require_relative 'foo'

class Bar < Foo
  # superclass -> Foo::X::Y
  class Yagni < superclass::X::Y
  end


  class BarInstance < superclass::FooInstance
    class Zed < BarInstance::Foo::FooInstance
    end

    # superclass -> Foo::FooInstance
    # In this instance of superclass
    # The value of @node_context.nesting is
    # ["Bar", "BarInstance", "CarInstance"]]

    # The lefthand side is included in the nest
    class CarInstance < superclass::FooInstance
    end
  end
end

# [Bar, BarInstance, CarInstance]
