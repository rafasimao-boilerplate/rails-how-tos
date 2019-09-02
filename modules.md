# Implemmenting Modules

Usually we implement modules to include in our classes, many times in our models. Here you can find some cheats to do it.

### Using ActiveSupport::Concern

```rb
module Example
  extend ActiveSupport::Concern

  class_methods do
    def foo; puts 'foo'; end

    private
      def bar; puts 'bar'; end
  end
end

class Buzz
  include Example
end

Buzz.foo # => "foo"
Buzz.bar # => private method 'bar' called for Buzz:Class(NoMethodError)
```
[reference](https://api.rubyonrails.org/v6.0.0/classes/ActiveSupport/Concern.html)
