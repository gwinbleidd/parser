require '../app/tlvfileconfig'

header = "FF804905CDF800100eDAT_PAYERS.tlvDF8340012GazpromCheAccountsDF822500820131220DF8367006201312DF84270011"

headercf = TLVFileConfig.new


block_start_tag = headercf.tag

block_start_length = header[block_start_tag.length .. block_start_tag.length + 2].to_i(16)

puts "Block: " + headercf.tag + "; Length: " + block_start_length.to_s

header = header[block_start_tag.length + 3 .. block_start_length + block_start_tag.length + 3]



file_tag = headercf.filename

file_name_length = header[file_tag.length .. file_tag.length + 2].to_i(16)

file_name = header[file_tag.length + 3 .. file_name_length + file_tag.length + 2]

puts "  Tag: " + file_tag + "; Length: " + file_name_length.to_s + "; Value: " + file_name

header[0 .. file_name_length + file_tag.length + 2] = ""



table_tag = headercf.tablename

table_name_length = header[table_tag.length .. table_tag.length + 2].to_i(16)

table_name = header[table_tag.length + 3 .. table_name_length + table_tag.length + 2]

puts "  Tag: " + table_tag + "; Length: " + table_name_length.to_s + "; Value: " + table_name

header[0 .. table_name_length + table_tag.length + 2] = ""



dateform_tag = headercf.dateform

dateform_length = header[dateform_tag.length .. dateform_tag.length + 2].to_i(16)

dateform = header[dateform_tag.length + 3 .. dateform_length + dateform_tag.length + 2]

puts "  Tag: " + dateform_tag + "; Length: " + dateform_length.to_s + "; Value: " + dateform

header[0 .. dateform_length + dateform_tag.length + 2] = ""



dicmonth_tag = headercf.dicmonth

dicmonth_length = header[dicmonth_tag.length .. dicmonth_tag.length + 2].to_i(16)

dicmonth = header[dicmonth_tag.length + 3 .. dicmonth_length + dicmonth_tag.length + 2]

puts "  Tag: " + dicmonth_tag + "; Length: " + dicmonth_length.to_s + "; Value: " + dicmonth

header[0 .. dicmonth_length + dicmonth_tag.length + 2] = ""



dictype_tag = headercf.dictype

dictype_length = header[dictype_tag.length .. dictype_tag.length + 2].to_i(16)

dictype = header[dictype_tag.length + 3 .. dictype_length + dictype_tag.length + 2]

puts "  Tag: " + dictype_tag + "; Length: " + dictype_length.to_s + "; Value: " + dictype

header[0 .. dictype_length + dictype_tag.length + 2] = ""





