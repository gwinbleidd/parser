# encoding: utf-8
require File.join(File.dirname(__FILE__), '../config/environment.rb')

conf = Configuration.new('mkd')
models = Model.new(conf.table[:dictionary])
out = OutputFile.new(conf)

out.start(models)