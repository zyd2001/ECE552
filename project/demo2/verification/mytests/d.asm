lbi r1, 13
lbi r2, 0
st r2, r1, 13
ld r2, r1, 13
bnez r2, .TEST
lbi r3, 2
.TEST:
lbi r3, 1
jal .TEST2
.TEST2:
add r7, r7, r7
halt