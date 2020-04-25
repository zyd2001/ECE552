// test for EX-ID forward path
lbi r0, 10
add r7, r0, r0
jalr r7, -12 // jump to line 7
.STOP:
halt
jalr r7, 10 // jump to line 11
halt
addi r7, r7, -2
jalr r7, 6 // jump to line 14
jalr r7, 2 // jump to line 9
halt
halt
jal .STOP