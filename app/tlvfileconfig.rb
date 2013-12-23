require 'yaml'

class TLVFileConfig

  CONFIG_FILE = 'tlv_file.yml'

  def load_settings
    @config ||= YAML.load(File.read(file_path))
  end

  def tag
    @tag = load_settings["header"]["tag"]
  end

  def filename
    @filename = load_settings["header"]["filename"]
  end

  def tablename
    @tablename = load_settings["header"]["tablename"]
  end

  def dateform
    @dateform = load_settings["header"]["dateform"]
  end

  def dicmonth
    @dicmonth = load_settings["header"]["dicmonth"]
  end

  def dictype
    @dictype = load_settings["header"]["dictype"]
  end

  def fieldblock
    @fieldblock = load_settings["fields"]["block"]
  end

  def fieldname
    @fieldname = load_settings["fields"]["field"]
  end

  def fieldvalue
    @fieldname = load_settings["fields"]["value"]
  end

  private

    def file_path
      "../conf/file/#{CONFIG_FILE}"
    end
end