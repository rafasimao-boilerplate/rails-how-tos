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

[reference link](https://nandovieira.com.br/usando-postgresql-e-jsonb-no-rails)
