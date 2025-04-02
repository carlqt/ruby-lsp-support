class Foo
  class X
    class Y
    end
  end

  class FooInstance
    class FooToo
    end
  end

  def greet
    puts 'Hello, World!'
  end
end

class Omega < Foo
  class OmegaInstance < superclass::FooInstance
  end
end
