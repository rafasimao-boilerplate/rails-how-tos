namespace :example_ns  do
  desc 'Migrates the ...'
  task migrate: :environment do
    from_url = ENV['MOD_MIGRATE_MEDIAS_FROM_URL']
    to_url = ENV['MOD_MIGRATE_MEDIAS_TO_URL']
    batch_size = ENV['MOD_MIGRATE_MEDIAS_BATCH_SIZE'].to_i
    
    start_date_env = ENV['MOD_MIGRATE_MEDIAS_START_DATE']
    start_date = DateTime.parse(start_date_env) if start_date_env
    
    pages = pages_to_migrate(start_date)

    prepare_data(pages)
    prepare_logs
    migrate(from_url, to_url, batch_size, pages)
  end

  private

  def pages_to_migrate(start_date)
    pages = start_date ? Page.where('updated_at > ?', start_date) : Page
  end

  def prepare_data(pages)
    @status_data = {
      unchanged: { message: 'Unchanged:', count: 0 },
      changed: { message: 'Migrated:', count: 0 },
      errors: { message: 'Error Saving:', count: 0 }
    }
    @progress_bar = ProgressBar.new(pages.count, :bar, :eta)
  end

  def prepare_logs
    timer = Time.now.strftime("%F_%H-%M")

    puts 'Creating log directories...'
    Dir.mkdir('log') unless File.exists?('log')
    Dir.mkdir('log/migrations') unless File.exists?('log/migrations')
    @unchanged_logger = Logger.new("log/migrations/unchanged_#{timer}.log")
    @info_logger = Logger.new("log/migrations/info_#{timer}.log")
    @error_logger = Logger.new("log/migrations/error_#{timer}.log")
  end

  def migrate(from, to, batch_size, pages)
    puts 'Migrating...'
    @info_logger.info("Migration Start -----------")

    pages.find_each(batch_size: batch_size) do |page|
      status = empty_page_status

      migrate_sections(page.sections, from, to, status)
      migrate_config(page.config, from, to, status)

      log_page_status(page, status)
    end

    @info_logger.info("Migration End -----------")
    @info_logger.info("Unchanged: #{@status_data[:unchanged][:count]}")
    @info_logger.info("Migrated: #{@status_data[:changed][:count]}")
    @info_logger.info("Errors: #{@status_data[:errors][:count]}")

    puts "\nDone!"
  end

  def empty_page_status
    {
      modified: false,
      error_config: false,
      error_sections: []
    }
  end

  def migrate_sections(sections, from, to, status)
    sections.each do |section|
      section.html = section.html.gsub(from, to)

      if section.changed?
        status[:modified] = true

        status[:error_sections] << section.id unless section.save
      end
    end
  end

  def migrate_config(config, from, to, status)
    return unless config && config.settings

    config.settings.each_pair do |key, value|
      config.settings[key] = value.gsub(from, to) if value.is_a?(String)
    end

    if config.changed?
      status[:modified] = true
      status[:error_config] = config.save
    end
  end

  def log_page_status(page, status)
    if status[:modified]
      log_page(page, :changed, @info_logger)

      if !status[:error_sections].empty? || status[:error_config]
        log_page(page, :errors, @error_logger)

        unless status[:error_sections].empty?
          @error_logger.error("Errors on sections with ids: #{status[:error_sections]*', '}")
        end

        if status[:error_config]
          @error_logger.error("Errors on PageConfiguration with id: #{page.config.id}")
        end
      end
    else
      log_page(page, :unchanged, @unchanged_logger)
    end
  end

  def log_page (page, status, logger)
    data = @status_data[status]

    data[:count] += 1
    @progress_bar.increment! 1

    logger.info("#{data[:message]} #Page id:#{page.id} domain:#{page.domain} optional_path:#{page.optional_path}")
  end
end
