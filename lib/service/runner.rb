require 'fileutils'
require 'active_support/core_ext'

module Minus5
  module Service
    module Runner
      extend Minus5::Log
      extend self

      #Conventions:
      #  called by script in bin directory
      #  finds application root ../ from calling script
      #  finds service name as application root directory name
      #  loads config from app_root/config/service.yml
      #  command is starting script name
      #  runs command on sevice
      def run
        command = Minus5.start_script_name
        app_root = Minus5.path_relative_to_start_script("/..")
        service_name = File.basename(app_root)
        class_name = service_name.camelize

        require "#{app_root}/lib/#{service_name}.rb"
        config = Minus5.load_config("#{app_root}/config/service.yml")
        config = config.merge default_options(app_root, service_name)

        service = eval(class_name).new(config)
        if service.respond_to?(command)  
          service.send(command)
        else
          log "No method #{command} in #{class_name}!"
        end        
      end

      private

      def default_options(app_root, service_name)
        {
          :app_root => app_root,
          :daemon => { 
            :backtrace  => true,
            :dir_mode   => :normal,
            :log_output => true,
            :app_name   => service_name,
            :dir        => app_root + '/tmp/pids',               
            :log_dir    => app_root + '/log',
          }
        }
      end

    end
  end
end
