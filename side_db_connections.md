```
module Klickpages
  class AbstractModel < ActiveRecord::Base
    self.abstract_class = true

    establish_connection "kp_#{Rails.env}".to_sym

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
      filename = "#{Rails.root}/db/kp_schema.rb"
      File.open(filename, 'w:utf-8') do |file|
        ActiveRecord::Base.establish_connection("kp_#{Rails.env}".to_sym)
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      end
    end
  end

  namespace :test do
    desc 'Purge and load kp_test schema'
    task :load_schema do
      klickpages_test_config = ActiveRecord::Base.configurations['kp_test']

      mysq_client = Mysql2::Client.new(klickpages_test_config.except('database'))
      mysq_client.query("DROP DATABASE IF EXISTS `#{klickpages_test_config['database']}`")
      mysq_client.query("CREATE DATABASE IF NOT EXISTS `#{klickpages_test_config['database']}`")
      mysq_client.close

      ActiveRecord::Base.establish_connection(klickpages_test_config)
      ActiveRecord::Schema.verbose = false

      load("#{Rails.root}/db/kp_schema.rb")
    end
  end


  namespace :kp do
    @kp_migrations_path = "db/kp_migrate"

    desc 'Create klickpages database...'
    task :create do
      puts 'Criando banco klickpages'
      client = Mysql2::Client.new(host: ENV['MOD_DATABASE_KP_HOST'],
                                  username: ENV['MOD_DATABASE_KP_USER'],
                                  password: ENV['MOD_DATABASE_KP_PASSWORD'])
      client.query("CREATE DATABASE IF NOT EXISTS #{ENV['MOD_DATABASE_KP_NAME']}")
      puts 'Banco criado com sucesso!'
    end

    desc 'Purge and load kp_database schema'
    task :load_schema do
      klickpages_config = Rails.configuration.database_configuration['kp_development']

      puts 'Iniciando conexão com o Mysql..'
      mysq_client = Mysql2::Client.new(klickpages_config.except('database'))
      mysq_client.query("CREATE DATABASE IF NOT EXISTS #{ENV['MOD_DATABASE_KP_NAME_TEST']}")
      mysq_client.close

      puts 'Estabilizando conexão...'
      ActiveRecord::Base.establish_connection(klickpages_config)
      ActiveRecord::Schema.verbose = false

      begin
        puts 'Carregando kp schema...'
        load("#{Rails.root}/db/kp_schema.rb")
        puts 'Carregamento completado!'
      rescue
        puts 'Kp schema já carregado!'
      end
    end

    desc 'Drop klickpages database'
    task :drop do
      klickpages_config = Rails.configuration.database_configuration['kp_development']
      puts 'Iniciando conexão com o Mysql..'
      mysq_client = Mysql2::Client.new(klickpages_config.except('database'))
      puts 'Apagando banco klickpages...'
      mysq_client.query("DROP DATABASE IF EXISTS `#{klickpages_config['database']}`")
    end

    desc 'Create klickpages database test'
    task :create_test do
      client = Mysql2::Client.new(host: ENV['MOD_DATABASE_KP_HOST'],
                                  username: ENV['MOD_DATABASE_KP_USER'],
                                  password: ENV['MOD_DATABASE_KP_PASSWORD'])
      client.query("CREATE DATABASE IF NOT EXISTS #{ENV['MOD_DATABASE_KP_NAME_TEST']}")
    end

    desc 'undo all kp migrations'
    task :rollback do
      Dir.entries(File.join(Rails.root, @kp_migrations_path)).sort.reverse_each do |file|
        do_task_on_migrate_file("db:kp:migrate:down",file)
      end
    end

    desc 'migrates all kp migrations'
    task :migrate do
      Dir.entries(File.join(Rails.root, @kp_migrations_path)).sort.each do |file|
        do_task_on_migrate_file("db:kp:migrate:up",file)
      end
    end

    namespace :migrate do
      # desc 'migrates one specific kp migration'
      task :up => [:environment] do
        version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
        raise "VERSION is required" unless version

        kp_connect
        ActiveRecord::Migrator.new(:up, migrations, version).migrate
      end

      # desc 'undo one specific kp migration'
      task :down => [:environment] do
        version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
        raise "VERSION is required" unless version

        kp_connect
        ActiveRecord::Migrator.new(:down, migrations, version).migrate
      end
    end


    def kp_connect
      return @kp_connection if @kp_connection
      kp_config = ActiveRecord::Base.configurations["kp_#{Rails.env}"]
      @kp_connection = ActiveRecord::Base.establish_connection(kp_config)
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
        ActiveRecord::MigrationContext.new(@kp_migrations_path).migrations
      else
        ActiveRecord::Migrator.migrations(@kp_migrations_path)
      end
    end

  end

end

```
