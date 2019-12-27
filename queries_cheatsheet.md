# Rails Queries CheatSheet

### Forcing to print query log on rails c

```rb
ActiveRecord::Base.logger = Logger.new(STDOUT)
```

### Inspecting table indexes

```rb
ActiveRecord::Base.connection.indexes(table).inspect
```

### Quering a jsonb

```rb
# preferences->newsletter = true
User.where('preferences @> ?', {newsletter: true}.to_json)
```

[usando-postgresql-e-jsonb-no-rails](https://nandovieira.com.br/usando-postgresql-e-jsonb-no-rails)

[how-to-query-jsonb-beginner-sheet-cheat](https://hackernoon.com/how-to-query-jsonb-beginner-sheet-cheat-4da3aa5082a3)

[useful postgresql queries](https://gist.github.com/rgreenjr/3637525)
