module Dictionary
  class InputFile
    def initialize
      @config||= YAML.load(File.read '..\config\dictionaries.yml')

      @config.each do |key, value|

      end

      validate @config
    end

    private
    def validate(config)
      puts config
    end
  end
end