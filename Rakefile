require 'rspec/core/rake_task'
 
RSpec::Core::RakeTask.new(:spec) 

task :default => :spec

task :run do
	ruby "app.rb"
end

namespace :db do
  task :create do
    sh "psql <sql/create-database-local.sql"
  end

  task :init do
    sh "psql opaldb <sql/init-table.sql"
  end
end

