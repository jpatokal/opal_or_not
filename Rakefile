require 'rspec/core/rake_task'
 
RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :run do
	ruby "app.rb"
end

task :deploy do
  sh "git push heroku master"
end

task :stats do
  sh "heroku pg:psql <sql/stats.sql"
end

namespace :db do
  namespace :local do
    task :create do
      sh "psql <sql/create-database-local.sql"
    end

    task :init do
      sh "psql 'app-dev' <sql/init-table.sql"
    end
  end

  namespace :prod do
    task :init do
      sh "heroku pg:psql <sql/init-table.sql"
    end
  end
end

