Capistrano::Configuration.instance(:must_exist).load do 

  #nakon deploya simlinkaj config fileove u /config dir
  #config fileovi se nalaze u shared/config
  after "deploy:update_code", "symlink_configs"
  task :symlink_configs do  
    run "ln -nfs #{shared_path}/config/service.yml #{release_path}/config/service.yml"
  end

  #start stop servisa
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

  after "deploy:setup", "fix_dir_permissions"
  task :fix_dir_permissions do
    dirs = [deploy_to, releases_path, shared_path]
    dirs += shared_children.map { |d| File.join(shared_path, d) }
    group = deploy_group || "admin"
    run "#{try_sudo} chgrp #{group} #{dirs.join(' ')}"
  end

  after "deploy:setup", "create_config_service_yml"
  task :create_config_service_yml do
    dirs = ["#{shared_path}/config"]
    run "#{try_sudo} mkdir -p #{dirs.join(' ')} && #{try_sudo} chmod g+w #{dirs.join(' ')}"
    run "#{try_sudo} chgrp #{deploy_group} #{dirs.join(' ')}"
    run "touch #{shared_path}/config/service.yml"
  end

end
