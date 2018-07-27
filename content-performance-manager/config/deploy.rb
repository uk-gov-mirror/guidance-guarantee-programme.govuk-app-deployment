set :application, "content-performance-manager"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"

set :run_migrations_by_default, true

load 'defaults'
load 'ruby'
load 'deploy/assets'

load 'govuk_admin_template'

set :rails_env, 'production'

namespace :deploy do
  namespace :content_performance_manager do
    desc "Restart the Google Analytics worker"
    task :restart_google_analytics_worker do
      run "sudo initctl restart content-performance-manager-google-analytics-worker-procfile-worker || "\
          "sudo initctl start content-performance-manager-google-analytics-worker-procfile-worker"
    end

    desc "Restart the Publishing API worker"
    task :restart_publishing_api_worker do
      run "sudo initctl restart content-performance-manager-publishing-api-worker-procfile-worker || "\
          "sudo initctl start content-performance-manager-publishing-api-worker-procfile-worker"
    end

    desc "Restart the Publishing API consumer"
    task :restart_publishing_api_consumer do
      run "sudo initctl restart content-performance-manager-publishing-api-consumer-procfile-worker ||"\
          "sudo initctl start content-performance-manager-publishing-api-consumer-procfile-worker"
    end

    desc "Restart the Publishing API bulk import consumer"
    task :restart_publishing_api_bulk_import_consumer do
      run "sudo initctl restart cpm-bulk-import-publishing-api-consumer-procfile-worker ||"\
          "sudo initctl start cpm-bulk-import-publishing-api-consumer-procfile-worker"
    end
  end
end

after "deploy:restart", "deploy:content_performance_manager:restart_google_analytics_worker"
after "deploy:restart", "deploy:content_performance_manager:restart_publishing_api_worker"
after "deploy:restart", "deploy:content_performance_manager:restart_publishing_api_consumer"
after "deploy:restart", "deploy:content_performance_manager:restart_publishing_api_bulk_import_consumer"
