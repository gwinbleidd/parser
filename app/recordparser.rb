#encoding: cp1251

require '../app/tlvfileconfig'

record = "FF804B08aDF842A007ACCOUNTDF842B00802003255DF842A003FIODF842B019Яковлева Ирина ЕвгеньевнаDF842A007ADDRESSDF842B022Сокол Советская  д.94 корп.1 кв.58"

recordcf = TLVFileConfig.new


block_start_tag = recordcf.fieldblock

block_start_length = record[block_start_tag.length .. block_start_tag.length + 2].to_i(16)

puts "Block: " + recordcf.tag + "; Length: " + block_start_length.to_s

record = record[block_start_tag.length + 3 .. block_start_length + block_start_tag.length + 3]

puts record