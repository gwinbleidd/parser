require 'dbf'


table = DBF::Table.new '..\DAT_PAYERS.dbf', nil, 'cp866'

def put_tlv(tag, value)
  tag.to_s+value.to_s.length.to_s(16).rjust(3,'0')+value.to_s
end



s = ""

File.delete('..\DAT_PAYERS.tlv')
$stdout = File.open('..\DAT_PAYERS.tlv', 'w')

s = 'FF8049'
s << put_tlv('DF8001','DAT_PAYERS.tlv')
s << put_tlv('DF8340','GazpromCheAccounts')
s << put_tlv('DF8225','20131220')
s << put_tlv('DF8367','201312')
s << put_tlv('DF8427','1')

puts s

s = ""

table.each do |record|
  s = 'FF804B'
  s << put_tlv('DF842A','ACCOUNT')
  s << put_tlv('DF842B',record.op_pa_cnt)
  s << put_tlv('DF842A','FIO')
  s << put_tlv('DF842B',record.op_pa_fio)
  s << put_tlv('DF842A','ADDRESS')
  s << put_tlv('DF842B',record.op_pa_adr)

  puts s
  s = ""
end
