require 'rubygems'
require 'active_record'
require 'yaml'
require '../lib/models/dictionaries'
require 'digest/md5'

class ConfigFile
  def config
    @config||= YAML.load(File.read '../config/dictionaries.yml')
  end

  def input_config(dict_name)
    @input_config||= YAML.load(File.read input_path(dict_name))
  end

  def output_config(dict_name)
    @output_config||= YAML.load(File.read output_path(dict_name))
  end

  def upload_input_config(dict_name)
    dict_record = Dictionaries.find_by(:name => dict_name)
    if dict_record == nil
      dict_record = Dictionaries.new
      dict_record.name = dict_name
      dict_record.input_config = File.read input_path(dict_name)
      dict_record.input_config_md5 = Digest::MD5.file(input_path(dict_name)).hexdigest.to_s
      dict_record.save
    elsif dict_record.input_config_md5 != Digest::MD5.file(input_path(dict_name)).hexdigest.to_s
      dict_record.input_config = File.read input_path(dict_name)
      dict_record.input_config_md5 = Digest::MD5.file(input_path(dict_name)).hexdigest.to_s
      dict_record.save
    end
  end

  def upload_output_config(dict_name)
    dict_record = Dictionaries.find_by(:name => dict_name)
    if dict_record == nil
      dict_record = Dictionaries.new
      dict_record.name = dict_name
      dict_record.output_config = File.read output_path(dict_name)
      dict_record.output_config_md5 = Digest::MD5.file(output_path(dict_name)).hexdigest.to_s
      dict_record.save
    elsif dict_record.output_config_md5 != Digest::MD5.file(output_path(dict_name)).hexdigest.to_s
      dict_record.output_config = File.read output_path(dict_name)
      dict_record.output_config_md5 = Digest::MD5.file(output_path(dict_name)).hexdigest.to_s
      dict_record.save
    end
  end

  private
    def validate(config)
      config
    end

    def input_path(dict_name)
      "../config/#{dict_name}/input.yml"
    end

    def output_path(dict_name)
      "../config/#{dict_name}/output.yml"
    end
end