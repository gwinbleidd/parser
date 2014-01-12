require './config/environment.rb'

# Документация по rake docs.rubyrake.org/
# namespace -- rake.rubyforge.org/classes/Rake/NameSpace.html

namespace :db do
  desc "Migrate the database"
  task :migrate do
    # выполнение всех миграций из lib/db/migrate,
    # метод принимает параметры: migrate(migrations_path, target_version = nil)
    # миграция запускается как rake db:migrate VERSION=номер_версии
    ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
  end
end
