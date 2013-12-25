#encoding: cp1251

require './tlvfileconfig'

record = "FF804B08aDF842A007ACCOUNTDF842B00802003255DF842A003FIODF842B019Яковлева Ирина ЕвгеньевнаDF842A007ADDRESSDF842B022Сокол Советская  д.94 корп.1 кв.58"

recordcf = TLVFileConfig.new

def get_block (record, block_tag)
  @get_block = Hash.new
  @get_block["tag"] = block_tag
  @get_block["length"] = record[block_tag.length .. block_tag.length + 2].to_i(16)
  @get_block["block"] = record[block_tag.length + 3 .. @get_block["length"] + block_tag.length + 3]
  @get_block
end

def parse_record (record, field_tag, value_tag)
  @rds = Hash.new

  loop do
    field_length = record[field_tag.length .. field_tag.length + 2].to_i(16)
    field = record[field_tag.length + 3 .. field_length + field_tag.length + 2]

    record[0 .. field_length + field_tag.length + 2] = ''

    value_length = record[value_tag.length .. value_tag.length + 2].to_i(16)
    value = record[value_tag.length + 3 .. value_length + value_tag.length + 2].encode('UTF-8')

    record[0 .. value_length + value_tag.length + 2] = ''

    @rds[field] = value

    break record if record.empty?
  end

  @rds
end

puts get_block(record, recordcf.fieldblock)

puts "Block: " + get_block(record, recordcf.fieldblock)["tag"] + "; Length: " + get_block(record, recordcf.fieldblock)["length"].to_s

records = parse_record(get_block(record, recordcf.fieldblock)["block"], recordcf.fieldname, recordcf.fieldvalue)

records.each {|k,v| puts "#{k}, #{v}"}
