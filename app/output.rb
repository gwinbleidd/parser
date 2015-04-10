# encoding: utf-8
require File.join(File.dirname(__FILE__), '../config/environment.rb')

ENV['ENV'] = 'development'

require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'
require '../lib/configuration'

conf = Configuration.new('mkd')
models = Model.new(conf.table[:dictionary])
out = OutputFile.new(conf)

out.start(models)