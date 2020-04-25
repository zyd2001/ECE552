// test for EX-ID forward condition
j .START
data 0x0005
data 0x0005
.START:
lbi r0, 12
jalr r0, -2
addi r1, r0, 0
bgez r1, .GO
halt

.GO:
lbi r2, 2
.LOOP1:
addi r0, r0, -1
st r0, r2, 0
ld r0, r2, 0
bgez r0, .LOOP1

lbi r2, 4
ld r0, r2, 0
.LOOP2:
addi r0, r0, -1
bgez r0, .LOOP2
halt