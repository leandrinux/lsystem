# this is the first in a series of test programs
# for the new snowshoe compiler

.code

  xor ah, ah
loop: 
  add ah, 1
  jmp loop
