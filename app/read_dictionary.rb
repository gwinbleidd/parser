require 'active_record'
require File.dirname(__FILE__) + '/dictionary'
require 'yaml'
ENV['RAILS_ENV'] = ARGV.first || ENV['RAILS_ENV'] || 'development'
require File.expand_path(File.dirname(__FILE__) + '/../config/environment')

dict = Dictionary.new

#puts dict.get_config('fryazinovo')['dictionaries']['abonent']

#config = dict.get_config('fryazinovo')
#
#puts config

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

records = dict.get_records('fryazinovo')

FryazinovoStreet.delete_all

records['street'].each { |k, v|
  #puts "#{k}, #{v}"

  street = FryazinovoStreet.create! v

  puts "#{street.streetId}, #{street.streetName}"

  #sql1 = "insert into " + 'fryazinovo'.capitalize + 'street'.capitalize + "("
  #sql2 = "\nvalues ("
  #v.each { |k1,v1|
  #  sql1 << k1.to_s + ', '
  #  sql2 << v1.to_s + ', '
  #}
  #
  #puts sql1+sql2
  #
  #sql1 = sql2 = ''
}

#puts dict.get_records('fryazinovo')['city'][1]

#yml = File.new('../records.yml', 'w+')
#
#yml.puts dict.get_records('fryazinovo').to_yaml

