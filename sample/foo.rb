class Foo
  class FooInstance
  end

  def greet
    puts 'Hello, World!'
  end
end

class Omega < Foo
  class OmegaInstance < superclass::FooInstance
  end
end
