$LOAD_PATH.unshift '.'

ENV['ISSOLA_SKIP_MODELS'] = '1'
ENV['LARRY_SKIP_MODELS']  = '1'

require 'bin/boot'

require 'issola/tasks/migrate'

namespace :larry do
  namespace :db do
    # Using a separate table to track migrations will prevent conflicts with
    # `issola`'s migrations.
    LARRY_SEQUEL_SCHEMA_TABLE = :schema_larry

    desc 'Apply DB migrations of Issola up to `version`, all if none specified.'
    task :migrate, [:version] do |t, args|
      # Don't load models when executing DB migrations.
      # This is required, since some of the tables they refer to might not exist
      # yet. It also prevents accidentally using them within migrations - which
      # is asking for trouble anyway.
      ENV['LARRY_SKIP_MODELS'] = '1'
      require 'bin/boot'

      # Will ensure it works no matter from which folder it's executed.
      migrations_path = File.join(__dir__, 'db', 'migrations')
      puts "Loading from: #{ migrations_path }"

      Sequel.extension :migration
      db = Sequel::Model.db
      if args[:version]
        Sequel::Migrator.run(db, migrations_path, target: args[:version].to_i, table: LARRY_SEQUEL_SCHEMA_TABLE)
      else
        Sequel::Migrator.run(db, migrations_path, table: LARRY_SEQUEL_SCHEMA_TABLE)
      end
    end
  end
end
