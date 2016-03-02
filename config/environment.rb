require 'logger'
require 'singleton'
require 'yaml'
require 'awesome_print'
require 'optparse'
require 'active_record'
require 'digest'
require 'zip'

ENV['ENV'] ||= 'development'

require File.expand_path('../application', __FILE__)

SCParser::Application.initialize!