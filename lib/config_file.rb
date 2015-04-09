require 'rubygems'
require 'active_record'
require 'yaml'
require '../lib/models/dictionaries'
require 'digest/md5'

class ConfigFile
  def config
    @config||= YAML.load(File.read '../config/dictionaries.yml')
  end
end