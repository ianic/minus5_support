#stdlib
require 'yaml'
#gems
require 'active_support/core_ext'

$LOAD_PATH.unshift File.dirname(__FILE__)
require 'core/deep_symbolize_keys.rb'
require 'core/log.rb'
require 'service/runner.rb'
require 'service/starter.rb'
require 'service/base.rb'
require 'sql_server/sql_server_adapter.rb'


module Minus5
  extend self

  def load_config(file)
    file_name = file.start_with?("/") ? file : "#{Dir.pwd}/#{file}"
    return {} unless File.exists?(file_name)
    hash = YAML.load_file file_name
    return hash.deep_symbolize_keys!
  end

  def path_relative_to_start_script(relative)
    File.absolute_path("#{File.expand_path(File.dirname($0))}#{relative}")
  end

  def start_script_name
    File.basename($0)
  end


end
