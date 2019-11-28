# Creating a New Rails Api 6.0 Project

## Requirements

To create a new Rails Api 6.0 you will be required at least ruby 2.5.0, so if you are below it update your ruby.

### RVM

Use the Ruby Version Manager to manage your ruby versions.

You can install it with:
```sh
curl -L https://get.rvm.io | bash -s stable
```

And to use it to install the required version you can:
```sh
rvm install ruby-[version]
```

And finally you can use it as your new default ruby:
```sh
rvm --default use 2.4.1
```

### Rails 6.0

Some useful features you may wonder why they are there and even remove from your repository:

#### Frameworks
- Active Storage
- Action Cable
- Action Mailer
- Action Text

#### Libs
- Minitest
- Sprockets(as sugestion)

#### Gems
- sqlite3
- jbuilder(as sugestion)
- redis(as sugestion to run action cable)
- bcrypt(as sugestion for has_secure_password)
- image_processing(as sugestion for active storage)
- rack-cors(as sugestion for handling cross origin resource sharing)

- byebug
- spring

- tzinfo(for zoneinfo)

### Adding Stuff

Some other gems you may want to add to your repository:

- postgres
- pry
- rspec
- faker
