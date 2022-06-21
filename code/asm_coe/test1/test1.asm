.data 0x0000
    buf: .word 0x0000
    
.text 0x0000
ini:
	ori $16, $zero, 0
    	ori $17, $zero, 1
    	ori $18, $zero, 2
    	ori $19, $zero, 3
    	ori $20, $zero, 4
    	ori $21, $zero, 5
   	ori $22, $zero, 6
 	ori $23, $zero, 7
	lui $8,  0xFFFF
   	ori $28, $8, 0xF000
magic:
	lw $1, 0xC72($28)
	srl $1, $1, 5
	beq $1, $16, case0
	beq $1, $17, case1
	beq $1, $18, case4
	beq $1, $19, case3
	beq $1, $20, case2
	beq $1, $21, case5
	beq $1, $22, case6
	beq $1, $23, case7
####################################################################################################	
case0:
##light led	
	sw 	$12,	0xC62($28)						
	lw   $9,0xC70($28)
	sw 	$9,	0xC60($28)	
##judge

	and $7,$7,$zero
	addi $7,$7,31#count the valid bitwidth-1 in $t7
loop1: 

	and $10,$10,$zero
	or $10,$10,$9
	and $6,$6,$zero	
	srlv $6,$10,$7
	bne $6,$zero,exit1_1
	beq $7,$zero,exit1_1
	sub $7,$7,$17
	#j loop1
	beq $0,$0,loop1
exit1_1:
#sum from left
	and $4,$4,$zero
	ori $4,$4,31 # 4count the number of shift left
	sub $4,$4,$7
	
	and $3,$3,$zero #sum in 3
	and $2,$2,$zero
	addi $2,$2,1 #pow of 2 in 2
	
loop2:
		and $10,$10,$zero
	or $10,$10,$9
	sllv $10,$10,$4
	srl $6,$10,31 # test wether is 1 in t
	bne $6,$17,lable1
	add $3,$3,$2
lable1: 
	sll $2,$2,1
	addi $4,$4,1
	and $29,$29,$zero
	ori $11,$11,32
	beq $4,$11,exit1_2
	#j loop2
	beq $0,$0,loop2
	
exit1_2:
#compare the left and the right
	and $10,$10,$zero
	or $10,$10,$9
	
	beq $10,$3,istrue
	#not 
	and $12,$12,$zero
	sw   $12,0xC62($28)
	#j exit2	
	beq $0,$0,exit2
istrue:
	and $12,$12,$zero
	addi $12,$12,2
	sw   $12,0xC62($28)
exit2:
beq $0,$0,Exit

###################################################################################
case1:

lw $1, 0xC72($28)
sw $1,0xC62($28) 

input_1:    
  lw $1, 0xC72($28)
	srl $1, $1, 5 
	bne $1,$17,Exit
 lw   $26,0xC70($28)##
 sw   $26,0xC60($28) 
judge_in_1:
 lw $10, 0xC72($28)
 and $11, $10, $17
 beq $11, $17, judge_out_1
 #j input_1
 beq $0,$0,input_1
judge_out_1:
and $24,$24,$0
 or $24,$24,$26
 #判断最高位是否为1
 #srl $13,$24,15
 #beq $13,$0,b1
 #lui $24,0xFFFF
 #b1:
 lw $10, 0xC72($28)
 and $11, $10, $17
 beq $11, $0, confirm_input_1
 #j judge_out_1
 beq $0,$0,judge_out_1
confirm_input_1:

 ######后面要改成60显示
 #and $24,$24,$0
 #or $24,$24,$26
sw $24,0xC60($28)


input_2:
  lw $1, 0xC72($28)
	srl $1, $1, 5 
	bne $1,$17,Exit
 lw    $27, 0xC70($28)
 sw   $27,0xC60($28) 
judge_in_2:
 lw $10, 0xC72($28)
 and $11, $10, $18
 beq $11, $18, judge_out_2
 #j input_2
beq $0,$0,input_2
judge_out_2:

and $25,$25,$0
or $25,$25,$27
#判断最高位是否为1
#srl $13,$25,15
 #beq $13,$0,b2
 #lui $25,0xFFFF
 #b2:
 lw $10, 0xC72($28)
 and $11, $10, $18
 beq $11, $0, confirm_input_2
# j judge_out_2
  beq $0,$0,judge_out_2
  
confirm_input_2:
######后面要改成60显示
#and $25,$25,$0
#or $25,$25,$27
sw $25,0xC60($28)
  
  #j Exit
   
 
  beq $0,$0,Exit

###################################################################################

case2:
#yx


   lw $1, 0xC72($28)
	sw $1,0xC62($28)
  and $8, $24, $25
    sw $8, 0xC60($28) 
   
     #j Exit
    beq $0,$0,Exit
###################################################################################
case3:
#change from 2
  lw $1, 0xC72($28)
	sw $1,0xC62($28)
  
  or $8, $24, $25
    sw $8, 0xC60($28) 
     #j Exit
    beq $0,$0,Exit
###################################################################################
case4:
#yx
lw $1, 0xC72($28)
	sw $1,0xC62($28)

  xor $8, $24, $25
    sw $8, 0xC60($28) 

     #j Exit
    beq $0,$0,Exit
###################################################################################
case5:
#yx
 lw $1, 0xC72($28)
	sw $1,0xC62($28)
 
 sllv $8,$24,$25
 
 
    sw $8, 0xC60($28) 
    #j Exit
    beq $0,$0,Exit
###################################################################################
case6:
#yx
  
	lw $1, 0xC72($28)
	sw $1,0xC62($28)
	
 srlv $8,$24,$25
    sw $8, 0xC60($28) 
    #j Exit
    beq $0,$0,Exit
###################################################################################
case7:
#change from 6
    	lw $1, 0xC72($28)
	sw $1,0xC62($28)					
	
srl $13,$24,15
bne $13,$17,b1
	lui $14,  0xFFFF
   	or $24,$24, $14
b1:	

srl $13,$25,15
bne $13,$17,b2
	lui $14,  0xFFFF
   	or $25, $25, $14
b2:
			
	
	
  srlv $8,$24,$25
    sw $8, 0xC60($28) 
     #j Exit
    beq $0,$0,Exit

###################################################################################
Exit:
	
	#j magic
	beq $0,$0,magic
