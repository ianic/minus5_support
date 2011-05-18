require 'daemons'

module Minus5
  module Service
    class Starter
      include Minus5::Log

      def initialize(options)
        @options = options[:daemon]
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

    end		    
  end
end
