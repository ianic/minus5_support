require 'rubygems'
#require "minus5_support"
require "#{File.expand_path(File.dirname(__FILE__))}/../../../lib/minus5_support"


class ServiceTemplate < Minus5::Service::Base

  def loop    
    log "running"
    sleep 10
  end

end
