```
module OldModule
  class AbstractModel < ActiveRecord::Base
    self.abstract_class = true

    establish_connection "old_#{Rails.env}".to_sym

    before_save :set_timestamps

    protected

    def set_timestamps
      self.insert_date = Time.now if self.respond_to?(:insert_date) && !self.update_date
      self.update_date = Time.now if self.respond_to?(:insert_date)
    end
  end
end
```

```
namespace :db do
  namespace :schema do
    desc 'Dump additional database schema'
    task :dump => [:environment, :load_config] do
      filename = "#{Rails.root}/db/old_schema.rb"
      File.open(filename, 'w:utf-8') do |file|
        ActiveRecord::Base.establish_connection("old_#{Rails.env}".to_sym)
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      end
    end
  end

  namespace :test do
    desc 'Purge and load old_test schema'
    task :load_schema do
      db_test_config = ActiveRecord::Base.configurations['old_test']

      mysq_client = Mysql2::Client.new(db_test_config.except('database'))
      mysq_client.query("DROP DATABASE IF EXISTS `#{db_test_config['database']}`")
      mysq_client.query("CREATE DATABASE IF NOT EXISTS `#{db_test_config['database']}`")
      mysq_client.close

      ActiveRecord::Base.establish_connection(db_test_config)
      ActiveRecord::Schema.verbose = false

      load("#{Rails.root}/db/old_schema.rb")
    end
  end


  namespace :old do
    @old_migrations_path = "db/old_migrate"

    desc 'Create db database...'
    task :create do
      puts 'Criando banco db'
      client = Mysql2::Client.new(host: ENV['MOD_DATABASE_Old_HOST'],
                                  username: ENV['MOD_DATABASE_Old_USER'],
                                  password: ENV['MOD_DATABASE_Old_PASSWORD'])
      client.query("CREATE DATABASE IF NOT EXISTS #{ENV['MOD_DATABASE_Old_NAME']}")
      puts 'Banco criado com sucesso!'
    end

    desc 'Purge and load _database schema'
    task :load_schema do
      db_config = Rails.configuration.database_configuration['old_development']

      puts 'Iniciando conexão com o Mysql..'
      mysq_client = Mysql2::Client.new(db_config.except('database'))
      mysq_client.query("CREATE DATABASE IF NOT EXISTS #{ENV['MOD_DATABASE_old_NAME_TEST']}")
      mysq_client.close

      puts 'Estabilizando conexão...'
      ActiveRecord::Base.establish_connection(db_config)
      ActiveRecord::Schema.verbose = false

      begin
        puts 'Carregando old schema...'
        load("#{Rails.root}/db/old_schema.rb")
        puts 'Carregamento completado!'
      rescue
        puts 'old schema já carregado!'
      end
    end

    desc 'Drop db database'
    task :drop do
      db_config = Rails.configuration.database_configuration['old_development']
      puts 'Iniciando conexão com o Mysql..'
      mysq_client = Mysql2::Client.new(db_config.except('database'))
      puts 'Apagando banco db...'
      mysq_client.query("DROP DATABASE IF EXISTS `#{db_config['database']}`")
    end

    desc 'Create db database test'
    task :create_test do
      client = Mysql2::Client.new(host: ENV['MOD_DATABASE_old_HOST'],
                                  username: ENV['MOD_DATABASE_old_USER'],
                                  password: ENV['MOD_DATABASE_old_PASSWORD'])
      client.query("CREATE DATABASE IF NOT EXISTS #{ENV['MOD_DATABASE_old_NAME_TEST']}")
    end

    desc 'undo all old migrations'
    task :rollback do
      Dir.entries(File.join(Rails.root, @old_migrations_path)).sort.reverse_each do |file|
        do_task_on_migrate_file("db:old:migrate:down",file)
      end
    end

    desc 'migrates all old migrations'
    task :migrate do
      Dir.entries(File.join(Rails.root, @old_migrations_path)).sort.each do |file|
        do_task_on_migrate_file("db:old:migrate:up",file)
      end
    end

    namespace :migrate do
      # desc 'migrates one specific old migration'
      task :up => [:environment] do
        version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
        raise "VERSION is required" unless version

        old_connect
        ActiveRecord::Migrator.new(:up, migrations, version).migrate
      end

      # desc 'undo one specific old migration'
      task :down => [:environment] do
        version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
        raise "VERSION is required" unless version

        old_connect
        ActiveRecord::Migrator.new(:down, migrations, version).migrate
      end
    end


    def old_connect
      return @old_connection if @old_connection
      old_config = ActiveRecord::Base.configurations["old_#{Rails.env}"]
      @old_connection = ActiveRecord::Base.establish_connection(old_config)
    end

    def do_task_on_migrate_file(task, file)
      if match_data = /(\d{14})_(.+)\.rb/.match(file)
        ENV["VERSION"] = match_data[0]
        Rake::Task[task].invoke
        Rake::Task[task].reenable
      end
    end

    def migrations
      migrations = if ActiveRecord.version.version >= '5.2'
        ActiveRecord::MigrationContext.new(@old_migrations_path).migrations
      else
        ActiveRecord::Migrator.migrations(@old_migrations_path)
      end
    end

  end

end

```
