module SCParser
  class GeneralFile
    def initialize(params)
      @log = ParserLogger.instance
      @properties = params[:properties]
      @file = params[:file]
      @rows_processed = {
          size: 0,
          joined: 0,
          inserted: 0,
          updated: 0
      }
    end
  end
end