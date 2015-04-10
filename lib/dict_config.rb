require 'config_file'

class DictConfig
  attr_reader :name, :file_properties

  def initialize(dict_name)
    @name = dict_name
    @cf = ConfigFile.new
    @file_properties = @cf.config[@name]
  end

  def input_config
    @input_config||= YAML.load(File.read input_path(self.name))
  end

  def output_config
    @output_config||= YAML.load(File.read output_path(self.name))
  end

  def upload_config
    dict_record = Dictionaries.find_by(:name => self.name)
    if dict_record == nil
      Dictionaries.create(:name => self.name,
                          :input_config => File.read(input_path(self.name)),
                          :input_config_md5 => Digest::MD5.file(input_path(self.name)).hexdigest.to_s,
                          :output_config => File.read(output_path(self.name)),
                          :output_config_md5 => Digest::MD5.file(output_path(self.name)).hexdigest.to_s)
    elsif dict_record.input_config_md5 != Digest::MD5.file(input_path(self.name)).hexdigest.to_s
      dict_record.update(:input_config => File.read(input_path(self.name)),
                         :input_config_md5 => Digest::MD5.file(input_path(self.name)).hexdigest.to_s)
    elsif dict_record.output_config_md5 != Digest::MD5.file(output_path(self.name)).hexdigest.to_s
      dict_record.update(:output_config => File.read(output_path(self.name)),
                         :output_config_md5 => Digest::MD5.file(output_path(self.name)).hexdigest.to_s)
    end
  end

  private
  def input_path(dict_name)
    "../config/#{dict_name}/input.yml"
  end

  def output_path(dict_name)
    "../config/#{dict_name}/output.yml"
  end
end