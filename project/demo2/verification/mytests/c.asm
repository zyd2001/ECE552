lbi r1, 123
st r1, r1, 1
ld r2, r1, 1
bnez r2, .TEST
lbi r3, 2
.TEST:
lbi r3, 1
halt
addi r3, r3, 1