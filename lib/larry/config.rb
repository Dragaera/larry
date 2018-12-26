require 'issola/persistence'

module Larry
  module Config
    module DB
      ADAPTER  = 'postgres'
      HOST     = ENV['DB_HOST']
      # If undefined, `nil`.to_i would be 0, whereas we want the adpater to use
      # its default if undefined.
      PORT     = if ENV.key?('DB_PORT')
                   ENV.fetch('DB_PORT').to_i
                 else
                   nil
                 end
      DATABASE = ENV['DB_DATABASE']
      USER     = ENV['DB_USER']
      PASSWORD = ENV['DB_PASSWORD']

      Issola::Persistence.initialize(
        {
          adapter:  ADAPTER,
          host:     HOST,
          port:     PORT,
          database: DATABASE,
          user:     USER,
          password: PASSWORD,
          test:     true,
        }
      )
    end

    module Larry
      ADMIN_USERS = ENV.fetch('LARRY_ADMIN_USERS', '').split(',')
    end

    module EICStock
      SESSION_CONFIGURATION_FILE = ENV.fetch('EIC_STOCK_SESSION_CONFIGURATION_FILE', 'data/google_api.json')
      SPREADSHEET_KEY = ENV.fetch('EIC_STOCK_SPREADSHEET_KEY')
    end
  end
end
