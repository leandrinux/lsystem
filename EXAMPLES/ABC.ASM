# ABC program 
#
# this is a test program that will output to a device the 'A' to 'Z' sequence of characters

.data

 define DEVICE = 1,  # DEVICE is the device number that will receive the sequence of characters
        COUNT = 26   # COUNT is the number of characters in the alphabet - the full length of the sequence

.code

  mov al, COUNT   # al is decremented until it becomes zero, when this happens the program ends
  mov ah, 'A'     # ah is the character that we are sending to the device
  
loop:
  out DEVICE, ah
  add ah, 1
  sub al, 1
  jnz loop
