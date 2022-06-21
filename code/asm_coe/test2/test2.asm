.data 0x0000
	space: .space 160
	
.text 0x0000
start: 
	lui   $1,0xFFFF			
        ori   $28,$1,0xF000
	add $22, $0, $0	
	ori  $26, $26, 1
	addi $21, $21, 128
	lui $3,  0x02FF
	ori $3, $3, 0xFFFF		# $7 = 0010 1111 1111 1111 1111 1111 1111
        #8号寄存器存起始地址base（全0），9号寄存器存space长度???
judge:
	lw    $1,0xC72($28)
	sw   $1,0xC62($28)	#发送键不按就会一直停在这？？？
	beq $22, $0, confirm_case_even

confirm_case_odd:
	lw $24, 0xC72($28)
	srl $24, $24, 1
	and $25, $24, $26
	bne $25, $26, judge
	add $22, $0, $0	#$22 = 0
	beq $0, $0, do_case

confirm_case_even:
	lw $24, 0xC72($28)
	and $25, $24, $26
	bne $25, $26, judge
	add $22, $0, $26	#$22 = 1
	beq $0, $0, do_case


do_case:
	sw $0, 0xC60($28)
	srl $1, $1, 5
	add $27, $0, $0	#清理27
	beq $1, $27, load_data #27号寄存器存用例编号数值用于判断beq，初始编号为000
	addi $27, $0, 1
	beq $1, $27, sort_1
	addi $27, $27, 1
	beq $1, $27, load_2
	addi $27, $27, 1
	beq $1, $27, sort_3
	addi $27, $27, 1
	beq $1, $27, max_minus_min_1
	addi $27, $27, 1
	beq $1, $27, max_minus_min_3
	addi $27, $27, 1
	beq $1, $27, low_8_bit
	addi $27, $27, 1
	beq $1, $27, show_msg
	
load_data:
	lw   $1,0xC70($28)	#读入要存入的数的个数				
	sw   $1,0xC60($28)
judge_num_in:
	lw $24, 0xC72($28)
	sw $24, 0xC62($28)
	beq $22, $0, even_num_in

odd_num_in:
	lw $24, 0xC72($28)
	srl $24, $24, 1
	and $25, $24, $26
	bne $25, $26, load_data
	add $22, $0, $0	# $22 = 0
	beq $0, $0, confirm_num

even_num_in:
	lw $24, 0xC72($28)
	and $25, $24, $26
	bne $25, $26, load_data
	add $22, $0, $26	# $22 = 1
	beq $0, $0, confirm_num


confirm_num:
	add $9, $0, $1		#9号寄存器存要存入的数的个数
	addi $10, $0, 0		#10号寄存器存当前正在输入第几个数
	addi $11, $0, 0		#11号寄存器存当前起始地址
	addi $12, $0, 40		#12号寄存器存1号数据集起始地址
load_loop: 
	lw $1,0xC70($28)				
	sw $1,0xC60($28)
	beq $22, $0, even_input_in

odd_input_in:
	lw $24, 0xC72($28)
	sw $24, 0xC62($28)
	srl $24, $24, 1
	and $25, $24, $26
	bne $25, $26, load_loop
	and $22, $0, $0	# $22 = 0
	beq $0, $0, store_input

even_input_in:
	lw $24, 0xC72($28)
	sw $24, 0xC62($28)
	and $25, $24, $26
	bne $25, $26, load_loop
	add $22, $0, $26    	# $22 = 1	
	beq $0, $0, store_input

store_input:
	sw $1, 0($11)
	sw $1, 0($12)		#先按同样的顺序存入1号数据集中，再在下一个样例进行排序
	addi $11, $11, 4	#当前地址+1byte/+4bit
	addi $12, $12, 4
	addi $10, $10, 1
	bne $9, $10, load_loop  

	addi $10, $0, 0			#还原数据
	addi $11, $0, 0
	addi $12, $0, 0
	beq $0, $0, judge

sort_1:
	#10号寄存器存外层变量，11号寄存器存内层变量，12号寄存器存a[i]，13号寄存器存a[i+1]，14号寄存器存a[i]地址，a[i+1]地址为a[i]地址+4

	add $11, $0, $zero	# 每次执行外层循环都将内层循环的循环变量置为0
	sort_1_loop1:
		add $14, $0, $11
		sll $14, $14, 2		#x4才是对应到byte的地址
		addi $14, $14, 40
		lw $12, 0($14)
		lw $13, 4($14)		#读取a[i]和a[i+1]
		
		#15号寄存器判断a[i]是否大于a[i+1]
		sltu $15, $12, $13	#a[i] < a[i+1] -- $15==1
		bne $15, $0, sort_1_skip	#若ai < ai+1，跳入skip， 若大于等于，则交换值
		sw $12, 4($14)
		sw $13, 0($14)
	sort_1_skip:
		addi $11, $11, 1	#内层变量自增，判断是否满足循环条件
		addi $16, $11, 1	#判断现在处理到第几个数（下标为0 -> 第1个数）
		sub $17, $9, $10
		bne $16, $17, sort_1_loop1	#判断内层是否跑完
		addi $10, $10, 1
		sub $18, $9, $26
		bne $10, $18, sort_1	#判断外层变量是否跑完
	addi $10, $0, 0	#还原数据
	addi $11, $0, 0
	addi $12, $0, 0
	addi $13, $0, 0
	addi $14, $0, 0
	addi $15, $0, 0
	addi $16, $0, 0
	addi $17, $0, 0
	addi $18, $0, 0
	beq $0, $0, judge
		
load_2:
	addi $10, $0, 0		#10号寄存器存当前正在处理第几个数
	addi $11, $0, 80	#11号寄存器存2号数据集的起始地址
	addi $12, $0, 0		#12号寄存器存0号数据集的起始地址
	addi $15, $0, 120		#15号寄存器存3号数据集的起始地址，一起存入，在后面的样例再排序
	load2_loop:
		addi $10, $10, 1
		
		lw $13, 0($12)	#13号寄存器存0号数据集读出来的对应数
		slti $14, $13, 128	#14号寄存器判断13号寄存器是正数还是负数，如果是正数则14号寄存器=1
		beq $14, $26, positive
		beq $14, $0, negative
		positive:
			beq $0, $0, restore
		negative:					#21号寄存器 = 128  先用$13 - 128消去符号位 然后用128 - $13获取补码的值 然后加上符号位
			sub $13, $13, $21		# $13 = $13 - $21
			sub $13, $21, $13		# $13 = $21 - $13
			ori $13, $13, 0x80		# $13 = $13 | 1000 0000 
			beq $0, $0, restore
		restore:
			sw $13, 0($11)
			sw $13, 0($15)
			addi $11, $11, 4	#当前地址+1byte/+4bit
			addi $15, $15, 4
			addi $12, $12, 4
			bne $9, $10, load2_loop
	addi $10, $0, 0	#还原数据
	addi $11, $0, 0	
	addi $12, $0, 0
	addi $13, $0, 0
	addi $14, $0, 0
	addi $15, $0, 0
	beq $0, $0, judge

sort_3:
	#10号寄存器存外层变量，11号寄存器存内层变量，12号寄存器存a[i]，13号寄存器存a[i+1]，14号寄存器存a[i]地址，a[i+1]地址为a[i]地址+4
	add $11, $0, $zero	# 每次执行外层循环都将内层循环的循环变量置为0
	sort_3_loop1:
		add $14, $0, $11
		sll $14, $14, 2		#x4才是对应到byte的地址
		addi $14, $14, 120
		lw $12, 0($14)
		lw $13, 4($14)		#读取a[i]和a[i+1]
		andi $19, $12, 128	#19号读取a[i]的符号位
		andi $20, $13, 128	#20号读取a[i+1]的符号位
		
		#15号寄存器判断a[i]是否大于a[i+1]，需要特判的是a[i]和a[i+1]都小于0，以及a[i]和a[i+1]异号
		bne $19, $20, compare_different
		and $4, $19, $20	#4号寄存器判断是不是都为负数
		beq $4, $21, compare_all_negative
		beq $0, $0, compare_normal

		compare_different:	#a[i]和a[i+1]异号
			add $15, $15, $26
			beq $19, $21, compare_judge	#若a[i]<0, a[i+1]>=0，则正常判断，$15 == 1
			add $15, $0, $0		#若a[i]>=0, a[i+1]<0，则必须交换
			beq $0, $0, compare_judge
		compare_all_negative:
			slt $15, $13, $12
			beq $0, $0, compare_judge
		compare_normal:
			slt $15, $12, $13	#a[i] < a[i+1] -- $15==1

		compare_judge:
			bne $15, $0, sort_3_skip	#若ai < ai+1，跳入skip， 若大于等于，则交换值
			sw $12, 4($14)
			sw $13, 0($14)
	sort_3_skip:
		addi $11, $11, 1	#内层变量自增，判断是否满足循环条件
		addi $16, $11, 1	#判断现在处理到第几个数（下标为0 -> 第1个数）
		sub $17, $9, $10
		bne $16, $17, sort_3_loop1	#判断内层是否跑完
		addi $10, $10, 1
		sub $18, $9, $26
		bne $10, $18, sort_3	#判断外层变量是否跑完
	addi $10, $0, 0	#还原数据
	addi $11, $0, 0
	addi $12, $0, 0
	addi $13, $0, 0
	addi $14, $0, 0
	addi $15, $0, 0
	addi $16, $0, 0
	addi $17, $0, 0
	addi $18, $0, 0
	beq $0, $0, judge
	

max_minus_min_1:
	addi $10, $0, 0		#10号寄存器读当前正在处理第几个数（方便判断当前数是不是最大值）
	addi $11, $0, 36	#11号寄存器存当前处理的数的地址
	lw $12, 4($11)		#12号寄存器存数据集1的最小值
	find_max:
		addi $10, $10, 1
		addi $11, $11, 4	#更新当前数的地址
		bne $10, $9, find_max	
	lw $13, 0($11)		#13号寄存器存数据集1的最大值
	subu $13, $13, $12	#1号数据集是无符号数
	sw $13, 0xC60($28)
	#还原数据
	addi $10, $0, 0
	addi $11, $0, 0
	addi $12, $0, 0
	addi $13, $0, 0
	beq $0, $0, judge

max_minus_min_3:
	addi $10, $0, 0		#10号寄存器读当前正在处理第几个数（方便判断当前数是不是最大值）
	addi $11, $0, 116	#11号寄存器存当前处理的数的地址
	lw $12, 4($11)		#12号寄存器存数据集1的最小值
	find_max3:
		addi $10, $10, 1
		addi $11, $11, 4	#更新当前数的地址
		bne $10, $9, find_max3	
	lw $13, 0($11)		#13号寄存器存数据集1的最大值
	sub $13, $13, $12	#3号数据集是有符号数
	sw $13, 0xC60($28)
	#还原数据
	addi $10, $0, 0
	addi $11, $0, 0
	addi $12, $0, 0
	addi $13, $0, 0
	beq $0, $0, judge


low_8_bit:
	lw    $1,0xC70($28)
	sw   $1,0xC60($28)	#读输入的数据集编号并显示在led上，sw0, sw1的按键输入！！！
	beq $22, $0, even_8_bit

odd_8_bit:
	lw $24, 0xC72($28)
	sw $24, 0xC62($28)
	srl $24, $24, 1
	and $25, $24, $26
	bne $25, $26, low_8_bit
	add $22, $0, $0	#$22 = 0
	beq $0, $0, confirm_8_bit

even_8_bit:
	lw $24, 0xC72($28)
	sw $24, 0xC62($28)
	and $25, $24, $26
	bne $25, $26, low_8_bit
	add $22, $0, $26	#$22 = 1
	beq $0, $0, confirm_8_bit

confirm_8_bit:
	add $13, $0, $0	#清理13号寄存器
	andi $1, $1, 3		#除去sw23,sw22,sw21的输入
	addi $10, $0, 1		#10号寄存器存 判断输入的是第几个数据集 的数据
	beq $10, $1, deal_1
	addi $10, $10, 1
	beq $10, $1, deal_2
	addi $10, $10, 1
	beq $10, $1, deal_3	#未对不合法输入进行判断，所以一定要保证输入的数据集编号是1，2，3中的一个
	
	deal_1:
		addi $11, $0, 36		#11号寄存器存1号数据集的起始地址
		lw $1,0xC70($28)
		sw $1,0xC60($28)	#获取要读的数字的下标（从0开始！！！，读入后+1改成从1开始）
		beq $22, $0, even_deal_1

	odd_deal_1:
		lw $24, 0xC72($28)
		sw $24, 0xC62($28)
		srl $24, $24, 1
		and $25, $24, $26
		bne $25, $26, deal_1
		add $22, $0, $0	#$22 = 0
		beq $0, $0, confirm_deal_1

	even_deal_1:
		lw $24, 0xC72($28)
		sw $24, 0xC62($28)
		and $25, $24, $26
		bne $25, $26, deal_1
		add $22, $0, $26	#$22 = 1
		beq $0, $0, confirm_deal_1
		
	
	confirm_deal_1:
		addi $1, $1, 1
		addi $12, $0, 0		#12号寄存器存当前正在读第几个数
		find_num1:
			addi $12, $12, 1
			addi $11, $11, 4
			bne $12, $1, find_num1
		lw $13, 0($11)		#13号寄存器存读出的数
		andi $13, $13, 255	#取低8bit
		beq $0, $0, handle

	deal_2:
		addi $11, $0, 76		#11号寄存器存2号数据集的起始地址
		lw $1,0xC70($28)
		sw $1,0xC60($28)	#获取要读的数字的下标（从0开始！！！，读入后+1改成从1开始）
		beq $22, $0, even_deal_2

	odd_deal_2:
		lw $24, 0xC72($28)
		sw $24, 0xC62($28)
		srl $24, $24, 1
		and $25, $24, $26
		bne $25, $26, deal_2
		add $22, $0, $0	#$22 = 0
		beq $0, $0, confirm_deal_2

	even_deal_2:
		lw $24, 0xC72($28)
		sw $24, 0xC62($28)
		and $25, $24, $26
		bne $25, $26, deal_2
		add $22, $0, $26	#$22 = 1
		beq $0, $0, confirm_deal_2
		
	confirm_deal_2:
		addi $1, $1, 1
		addi $12, $0, 0		#12号寄存器存当前正在读第几个数
		find_num2:
			addi $12, $12, 1
			addi $11, $11, 4
			bne $12, $1, find_num2
		lw $13, 0($11)		#13号寄存器存读出的数
		andi $13, $13, 255	#取低8bit
		beq $0, $0, handle

	deal_3:
		addi $11, $0, 116		#11号寄存器存3号数据集的起始地址
		lw $1,0xC70($28)
		sw $1,0xC60($28)	#获取要读的数字的下标（从0开始！！！，读入后+1改成从1开始）
		beq $22, $0, even_deal_3

	odd_deal_3:
		lw $24, 0xC72($28)
		sw $24, 0xC62($28)
		srl $24, $24, 1
		and $25, $24, $26
		bne $25, $26, deal_3
		add $22, $0, $0	#$22 = 0
		beq $0, $0, confirm_deal_3

	even_deal_3:
		lw $24, 0xC72($28)
		sw $24, 0xC62($28)
		and $25, $24, $26
		bne $25, $26, deal_3
		add $22, $0, $26	#$22 = 1
		beq $0, $0, confirm_deal_3
		
	
	confirm_deal_3:		
		addi $1, $1, 1
		addi $12, $0, 0		#12号寄存器存当前正在读第几个数
		find_num3:
			addi $12, $12, 1
			addi $11, $11, 4
			bne $12, $1, find_num3
		lw $13, 0($11)		#13号寄存器存读出的数
		andi $13, $13, 255	#取低8bit
		beq $0, $0, handle
	
	handle:
		sw $13, 0xC60($28)
		add $13, $0, $0
		beq $0, $0, judge
		
show_msg:
		lw $1, 0xC70($28)
		sw $1, 0xC60($28)
		addi $1, $1, 1
		beq $22, $0, even_show_in

	odd_show_in:
		lw $24, 0xC72($28)
		sw $24, 0xC62($28)
		srl $24, $24, 1
		and $25, $24, $26
		bne $25, $26, show_msg
		add $22, $0, $0	#$22 = 0
		beq $0, $0, confirm_msg

	even_show_in:
		lw $24, 0xC72($28)
		sw $24, 0xC62($28)
		and $25, $24, $26
		bne $25, $26, show_msg
		add $22, $0, $26	#$22 = 1	
		beq $0, $0, confirm_msg

	confirm_msg:
		#先show数据集0
		addi $10, $0, 0		# 1号寄存器： 元素下标	 10号寄存器: 现在处理的是第几个数  11号寄存器：存现在数据的地址	13号寄存器：具体数值
		addi $11, $0, -4
		
		find_msg_1:
		addi $10, $10, 1
		addi $11, $11, 4
		bne $10, $1, find_msg_1
	
		lw $13, 0($11)
		andi $13, $13, 255
		sw $13, 0xC60($28)
		add $13, $0, $0
		beq $0, $0, msg_loop_1

	change_show:
		#再show数据集2
		addi $10, $0, 0		# 1号寄存器： 元素下标	3号寄存器：存显示时间	 10号寄存器: 现在处理的是第几个数  11号寄存器：存现在数据的地址	13号寄存器：具体数值
		addi $11, $0, 76
		
		find_msg_2:
		addi $10, $10, 1
		addi $11, $11, 4
		bne $10, $1, find_msg_2
	
		lw $13, 0($11)
		andi $13, $13, 255
		sw $13, 0xC60($28)
		add $13, $0, $0
		beq $0, $0, msg_loop_2	

	continue:
		beq $22, $0, even_no_show
	
	odd_no_show:
		lw $24, 0xC72($28)
		sw $24, 0xC62($28)
		srl $24, $24, 1
		and $25, $24, $26
		bne $25, $26, confirm_msg
		add $22, $0, $0	# $22 = 0
		beq $0, $0, exit

	even_no_show:
		lw $24, 0xC72($28)
		sw $24, 0xC62($28)
		and $25, $24, $26
		bne $25, $26, confirm_msg
		add $22, $0, $26	# $22 = 1
		beq $0, $0,  exit
		

	msg_loop_1:
		add $5, $0, $0
		until_five_sec_1:
		addi $5, $5, 1
		bne $5, $3, until_five_sec_1
		beq $0, $0, change_show

	msg_loop_2:
		add $5, $0, $0
		until_five_sec_2:
		addi $5, $5, 1
		bne $5, $3, until_five_sec_2
		beq $0, $0, continue

	exit:
		sw $0, 0xC60($28)
		beq $0, $0, judge
