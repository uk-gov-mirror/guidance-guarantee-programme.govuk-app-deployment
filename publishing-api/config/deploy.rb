set :application, "publishing-api"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, {
  publishing_api: { roles: [:db, :app, :web] },
  backend: { roles: [:app, :web] },
}

set :run_migrations_by_default, true

load 'defaults'
load 'ruby'

after "deploy:restart", "deploy:restart_procfile_worker"
after "deploy:notify", "deploy:notify:errbit"
