require 'active_record'
require File.dirname(__FILE__) + '/dictionary_config'
ENV['RAILS_ENV'] = ARGV.first || ENV['RAILS_ENV'] || 'development'
require File.expand_path(File.dirname(__FILE__) + '/../config/environment')

dict = Dictionary.new

#puts dict.get_config('fryazinovo')['dictionaries']['abonent']

config = dict.get_config('fryazinovo')

puts config

#config.each { |key, value|
#  s = "rails generate model "
#  value.each { |k, v|
#    s << 'fryazinovo'.capitalize + k.to_s.capitalize + ' '
#    for i in 1..v['fields'].size
#      s << v['fields']['column'+i.to_s]['name'] + ':' + v['fields']['column'+i.to_s]['type'] + ' '
#    end
#
#    puts `#{s.chop}`
#
#    s = "rails generate model "
#  }
#}


class ExternalApp < ActiveRecord::Base
  self.abstract_class = true
  def self.columns() @columns ||= []; end
end

test = %w['test']

puts test