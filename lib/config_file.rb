require 'rubygems'
require 'active_record'
require 'yaml'
require 'digest/md5'

class ConfigFile
  attr :config

  def initialize
    @config||= YAML.load(File.read '../config/dictionaries.yml')
  end
end