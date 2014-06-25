# encoding: utf-8
require File.join(File.dirname(__FILE__), '../config/environment.rb')

require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'

conf = Dictionary::Configuration.new('souz')
models = Dictionary::Model.new(conf.table)
out = Dictionary::OutputFile.new(conf)

out.start(models)