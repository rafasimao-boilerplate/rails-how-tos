# Creating an index concurrently

```ruby
class AddIndexToAsksActive < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :asks, :active, algorithm: :concurrently
  end
end
```

The caveat is that concurrent indexes must be created outside a transaction. By default, ActiveRecord migrations are run inside a transaction.
Use `disable_ddl_transaction!` to do this.

### Reference
[link](https://thoughtbot.com/blog/how-to-create-postgres-indexes-concurrently-in)
