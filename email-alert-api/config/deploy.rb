set :application, "email-alert-api"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :server_class, %w(email_alert_api backend)

set :run_migrations_by_default, true

load "defaults"
load "ruby"

after "deploy:restart", "deploy:restart_procfile_worker"
