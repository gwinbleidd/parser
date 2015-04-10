ENV['ENV'] = 'development'

require File.join(File.dirname(__FILE__), '../config/environment.rb')

require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'
require '../lib/config_file'
require '../lib/configuration'
require '../lib/model'
require '../lib/dict_config'
require '../lib/file_loader'
require '../lib/upload'

require 'awesome_print'

#cf = ConfigFile.new
#
# puts cf.config
# puts cf.input_config('mkd')
# puts cf.output_config('mkd')
# cf.upload_config('mkd')
# cf.upload_output_config('mkd')

#dc = DictConfig.new('mkd')
#ap dc.input_config
#ap dc.output_config

#c = Configuration.new('mkd')

#ap c.name
#ap c.table

#m = Model.new('mkd')

#ap m.config.table

#ap m.objects

# fl = FileLoader.new
# fl.start

u = Upload.new