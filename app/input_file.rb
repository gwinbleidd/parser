module Dictionary
  class InputFile
    def initialize
      @config||= YAML.load(File.read '..\config\dictionaries.yml')

      validate @config
    end

    private
    def validate(config)
      puts config
    end
  end
end