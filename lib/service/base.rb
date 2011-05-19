module Minus5
  module Service

    class Base
      include Minus5::Log

      def initialize(options)
        @terminate = false
        @options = options
      end

      def start
        Minus5::Service::Starter.new(@options).start
        Signal.trap("TERM") do
          @terminate = true
        end
        log "starting options: #{@options.inspect}"
        on_start        
        while !@terminate
          loop 
        end        
        on_stop
        log "stopped" 
      end
      
      def stop
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
          Kernel::sleep((delay - elapsed < 1) ? (delay - elapsed) : 1)
          elapsed = elapsed + 1           
        end
      end

    end
  end
end
