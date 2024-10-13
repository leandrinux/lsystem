# this program does nothing useful
# it's only used to test the tokenizer and the parser

.data

  def 
    OUTPUT_DEVICE = 0x01,
    OTHER_DEVICE = 0x02

  var 
    text: char = 'Hello World\0'

  var 
    tiny: byte,                # this will be initialized as zero
    medium: word = $FAFA,      # this will require bitsize verification
    large: long = $CAFECAFE

.code

main:
    mov eax, @text     # moves the address of 'text' to ah
    mov ah, text       # moves 'H' to ah
    mov bl, tiny       # moves zero to bl

    mov ebx, @medium   # moves the address of 'medium' to ebx
    mov [ebx], $AFAF   # assigns AFAF to the address contained in ebx, effectively changing 'medium'

    mov large, $ABC00CBA   # moves a value to the variable 'large'
