default_run_options[:pty] = true

set :application, "service"
set :deploy_to,   "/var/apps/service"

set :svn_root,      "https://svn.mobilnet.hr/SuperSport/monit/trunk/service"
set :svn_arguments, "--username deploy --password deploy --no-auth-cache"   
set :repository,    Proc.new { "#{svn_arguments} #{svn_root}" }

# set :runner, 'ianic'
# set :admin_runner, 'ianic'

server "5-zapisnicar.supersport.local", :app, :web, :db, :primary => true

#nakon deploya simlinkaj config fileove u /config dir
#config fileovi se nalaze u shared/config
after "deploy:update_code", "symlink_configs"
task :symlink_configs do  
  run "ln -nfs #{shared_path}/config/service.yml #{release_path}/config/service.yml"
end

namespace :deploy do
  desc "Restarting services"
  task :restart do
    run "#{current_path}/bin/stop"
    run "#{current_path}/bin/start"
  end

  desc "Stopping services"
  task :stop do
    run "#{current_path}/bin/stop"
  end

end
