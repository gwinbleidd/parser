ENV['PATH'] = "D:\\oracle\\instantclient_11_2;#{ENV['PATH']}"
ENV['NLS_LANG'] = 'AMERICAN_CIS.CL8MSWIN1251'
ENV['ENV'] ||= 'development'

require File.expand_path('../application', __FILE__)

Application.initialize!