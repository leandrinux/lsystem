# manually generated from FULL.ASM

.data
$00000000: 48 65 6C 6C 6F 20 57 6F 72 6C 64 00 # text
$0000000C: 00 # tiny
$0000000D: FA FA # medium
$0000000F: FE CA FE CA # large
$00000013
.code
$00000000: 01 10   50 00 00 00   00 00 00 00 # mov eax @text
$0000000A: 01 12   52 00 00 00   6C 6C 65 48 # mov eax text
$00000014: 01 10   52 00 00 00   65 00 00 00 # mov eax text+1
$0000001E: 01 12   63 00 00 00   0C 00 00 00 # mov bl tiny
$00000028: 01 10   60 00 00 00   0D 00 00 00 # mov ebx @medium
$00000032: 01 30   00 00 00 60   AF AF 00 00 # mov [ebx] $AFAF
$0000003C: 01 20   0F 00 00 00   BA 0C C0 AB # mov large $ABC00CBA
$00000046