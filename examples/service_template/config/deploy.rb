require 'minus5_support/service_deploy_tasks'

default_run_options[:pty] = true

set :application,   "service"
set :deploy_group,  "admin"
set :deploy_to,     "/var/apps/#{application}"
set :svn_root,      "https://svn.mobilnet.hr/SuperSport/monit/trunk/service"
set :svn_arguments, "--username deploy --password deploy --no-auth-cache"   
set :repository,    Proc.new { "#{svn_arguments} #{svn_root}" }

server "5-zapisnicar.supersport.local", :app, :web, :db, :primary => true
