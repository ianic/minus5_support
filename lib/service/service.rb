require 'pp'
require 'daemons'
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

    class Starter
      include Minus5::Log

      def initialize(options)
        @options = options[:daemon]
        # @app_root = options[:app_root]
        # add_defaults
      end

      def stop
        try_stop
      end

      def start
        make_dirs
        try_stop
        log "starting deamon: #{@options.inspect}"
        Daemons.daemonize(@options)
        pid = Process.pid
        @options[:pid] = pid
        pid
      end

      private 

      def make_dirs
        FileUtils.mkdir_p @options[:dir]
        FileUtils.mkdir_p @options[:log_dir]
      end
      
      def pid_file 
        "#{@options[:dir]}/#{@options[:app_name]}.pid"
      end
      
      def try_stop
        if File.exists?(pid_file)
          pid = File.read(pid_file).gsub("\n","")
          log "stoping pid: #{pid}"
          `kill #{pid}` 
          sleep 2
          `kill -9 #{pid}` if File.exists?(pid_file)
          true
        else
          false        
        end
      end

      # def add_defaults
      #   @options.reverse_merge!({ 
      #                             :backtrace  => true,
      #                             :dir_mode   => :normal,
      #                             :log_output => true,
      #                             :app_name   => "unnamed_service",
      #                             :dir        => @app_root + '/tmp/pids',               
      #                             :log_dir    => @app_root + '/log',
      #                           })
      # end

    end
    
    class Base
      include Minus5::Log

      def initialize(options)
        @terminate = false
        @options = options
      end

      def start
        #return unless @options[:daemon]
        Minus5::Service::Starter.new(@options).start
        Signal.trap("TERM") do
          @terminate = true
        end
        log "starting options: #{pp @options}"
        on_start        
        while !@terminate
          loop 
        end        
        on_stop
        log "stopped" 
      end
      
      def stop
        #return unless @options[:daemon]
        Minus5::Service::Starter.new(@options).stop
      end

      protected

      #callbacks
      def on_start        
      end
      def on_stop    
      end

      # sleep for delay, but check at least every second if TERM signal is received
      def sleep(delay)
        if delay < 1
          Kernel::sleep delay
          return
        end
        elapsed = 0        
        while !@terminate && elapsed < delay
          Kernel::sleep (delay - elapsed < 1) ? (delay - elapsed) : 1
          elapsed = elapsed + 1           
        end
      end

    end

  end
end
