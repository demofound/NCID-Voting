namespace :db do
  namespace :test do
    task :fresh => :environment do
        Rake::Task["db:drop"].invoke
        Rake::Task["db:create"].invoke
        Rake::Task["db:schema:load"].invoke
        Rake::Task["db:seed"].invoke
    end
  end
end
