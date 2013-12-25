# encoding: cp1251

require './tlvfileconfig'

header = "FF804905CDF800100eDAT_PAYERS.tlvDF8340012GazpromCheAccountsDF822500820131220DF8367006201312DF84270011"

def parse_header(header)
  headercf = TLVFileConfig.new
  @header = Hash.new

  headercf.load_settings["header"].each do |key,value|
    tag_length = header[header.index(value) + value.length .. header.index(value) + value.length + 2].to_i(16)
    tag_value = header[header.index(value) + value.length + 3 .. header.index(value) + value.length + tag_length + 2]
    @header[key] = tag_value
  end

  @header
end

puts parse_header(header)