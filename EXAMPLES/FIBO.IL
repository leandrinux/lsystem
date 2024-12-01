.code

00 00   00 00 00 00   00 00 00 00  ; $00000000: xor edx, edx     # set edx to 0
00 00   00 00 00 00   00 00 00 00  ; $0000000A: call line_no     # print the line number
00 00   00 00 00 00   00 00 00 00  ; $00000014: out 1, 48        # print 0
00 00   00 00 00 00   00 00 00 00  ; $0000001E: call eoln        # print CRLF
00 00   00 00 00 00   00 00 00 00  ; $00000028: mov edx, 1       # set edx to 1
00 00   00 00 00 00   00 00 00 00  ; $00000032: call line_no     # print the line number
00 00   00 00 00 00   00 00 00 00  ; $0000003C: out 1, 49        # print 1
00 00   00 00 00 00   00 00 00 00  ; $00000046: call eoln        # print CRLF
00 00   00 00 00 00   00 00 00 00  ; $00000050: xor ebx, ebx     # set ebx to 0  (first value in the sequence)
00 00   00 00 00 00   00 00 00 00  ; $0000005A: mov ecx, 1       # set ecx to 1  (second value in the sequence)
00 00   00 00 00 00   00 00 00 00  ; $00000064: loop: mov eax, ebx     
00 00   00 00 00 00   00 00 00 00  ; $0000006E: add eax, ecx     # eax = ebx + ecx
00 00   00 00 00 00   00 00 00 00  ; $00000078: add edx, 1       # increment the line number
00 00   00 00 00 00   00 00 00 00  ; $00000082: cmp edx, 47
00 00   00 00 00 00   00 00 00 00  ; $0000008C: jz end           # if the line number is 47 then end program
00 00   00 00 00 00   00 00 00 00  ; $00000096: call line_no        # print the line number
00 00   00 00 00 00   00 00 00 00  ; $000000A0: call write_uint32   # print the value calculated in eax
00 00   00 00 00 00   00 00 00 00  ; $000000AA: call eoln           # print CRLF
00 00   00 00 00 00   00 00 00 00  ; $000000B4: mov ebx, ecx
00 00   00 00 00 00   00 00 00 00  ; $000000BE: mov ecx, eax     # shift the values of the sequence
00 00   00 00 00 00   00 00 00 00  ; $000000C8: jmp loop         # continue with the next value
00 00   00 00 00 00   00 00 00 00  ; $000000D2: write_uint32: pusha      # prints a unsigned 32 bit integer
00 00   00 00 00 00   00 00 00 00  ; $000000DC: xor edx, edx
00 00   00 00 00 00   00 00 00 00  ; $000000E6: push 0
00 00   00 00 00 00   00 00 00 00  ; $000000F0: _get_digit: cmp edx, 3
00 00   00 00 00 00   00 00 00 00  ; $000000FA: jnz _next
00 00   00 00 00 00   00 00 00 00  ; $00000104: push '.'
00 00   00 00 00 00   00 00 00 00  ; $0000010E: xor edx, edx
00 00   00 00 00 00   00 00 00 00  ; $00000118: _next: add edx, 1
00 00   00 00 00 00   00 00 00 00  ; $00000122: mov ebx, eax
00 00   00 00 00 00   00 00 00 00  ; $0000012C: div ebx, 10
00 00   00 00 00 00   00 00 00 00  ; $00000136: mov ecx, eax
00 00   00 00 00 00   00 00 00 00  ; $00000140: mov eax, ebx
00 00   00 00 00 00   00 00 00 00  ; $0000014A: mul ebx, 10
00 00   00 00 00 00   00 00 00 00  ; $00000154: sub ecx, ebx
00 00   00 00 00 00   00 00 00 00  ; $0000015E: add ecx, 48
00 00   00 00 00 00   00 00 00 00  ; $00000168: push ecx
00 00   00 00 00 00   00 00 00 00  ; $00000172: jl 0, _get_digit
00 00   00 00 00 00   00 00 00 00  ; $0000017C: _write_digit: pop ecx
00 00   00 00 00 00   00 00 00 00  ; $00000186: cmp ecx, 0
00 00   00 00 00 00   00 00 00 00  ; $00000190: jz _end
00 00   00 00 00 00   00 00 00 00  ; $0000019A: out 1, cl
00 00   00 00 00 00   00 00 00 00  ; $000001A4: jmp _write_digit
00 00   00 00 00 00   00 00 00 00  ; $000001AE: _end: popa 
00 00   00 00 00 00   00 00 00 00  ; $000001B8: ret 
00 00   00 00 00 00   00 00 00 00  ; $000001C2: eoln: out 1, C_CR   # prints CRLF
00 00   00 00 00 00   00 00 00 00  ; $000001CC: out 1, C_LF
00 00   00 00 00 00   00 00 00 00  ; $000001D6: ret
00 00   00 00 00 00   00 00 00 00  ; $000001E0: line_no: push eax   # prints the number contained in edx
00 00   00 00 00 00   00 00 00 00  ; $000001EA: out 1, 'F'
00 00   00 00 00 00   00 00 00 00  ; $000001F4: mov eax, edx
00 00   00 00 00 00   00 00 00 00  ; $000001FE: call write_uint32
00 00   00 00 00 00   00 00 00 00  ; $00000208: out 1, ' '
00 00   00 00 00 00   00 00 00 00  ; $00000212: out 1, '='
00 00   00 00 00 00   00 00 00 00  ; $0000021C: out 1, ' '
00 00   00 00 00 00   00 00 00 00  ; $00000226: pop eax
00 00   00 00 00 00   00 00 00 00  ; $00000230: ret
00 00   00 00 00 00   00 00 00 00  ; $0000023A: end: xor eax, eax
