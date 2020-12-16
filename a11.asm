#;	Alexis Ugalde
#;	This program determines which widgets are within acceptable tolerances and outputs the results
.data
	widgetMeasurements: .word	706, 672, 658, 548, 570, 439, 648, 563, 790, 442
						.word	982, 904, 615, 718, 841, 827, 594, 673, 839, 762
						.word	547, 611, 620, 747, 858, 915, 509, 968, 774, 778
						.word	526, 934, 453, 910, 921, 766, 753, 849, 718, 479
						.word	910, 914, 481, 639, 614, 1049, 517, 501, 777, 860

	widgetTargetSizes:	.word	717, 662, 742, 502, 622, 511, 651, 645, 868, 517
						.word	895, 881, 539, 701, 779, 857, 653, 724, 907, 830
						.word	585, 574, 649, 750, 986, 930, 543, 932, 891, 760
						.word	603, 836, 509, 942, 864, 879, 668, 790, 806, 516
						.word	820, 834, 555, 588, 620, 926, 524, 517, 802, 988

	widgetStatus: .space 200

	WIDGET_COUNT = 50

	messageWidgetHeader: 	.asciiz "Widget #"
	messageWidgetAccepted:	.asciiz ": Accepted\n"
	messageWidgetRejected:	.asciiz ": Rejected\n"
	messageWidgetRework:	.asciiz ": Rework\n"

	SYSTEM_EXIT = 10
	SYSTEM_PRINT_INTEGER = 1
	SYSTEM_PRINT_STRING = 4

    widgetNum: .word 8
	
.text
.globl main
.ent main
main:


	la $t0, widgetMeasurements	# pointer to first arr
	la $t1, widgetTargetSizes	# pointer to second arr
	li $t5, 0					# counter 
    la $t2, widgetStatus
    
	#; Check Each Widget
	checkWidgetLp:
		#; Find Difference
		lw $t6, ($t1) 				# load current widgetMeasurements into t6 
		mul $t6, $t6, 8
		div $t6, $t6, 100 			# t6 = target * 8 / 100 

 		#; Find 8% Thresholds
		lw $t7, ($t1)				# current target measurements into t7 
		sub $t7, $t7 $t6 			# lower threshold by subtraction = target[i] - target[i] * 8/ 100 

		lw $t8, ($t1)				# current target measurements into t8
		add $t8, $t8 , $t6 			# upper threshold by addition = target[i] + target[i] * 8/ 100 

		#; Determine Widget Status  
        lw $t6, ($t0)
		bltu $t6, $t7, jumpLower     # comparing upper and lower to widgetMeasurements = cmp t7 & t8 to t0
		bgtu $t6, $t8, jumpUpper
        b accept 

		jumpLower: 
			#; Reject (< 92%) 
            li $t9, -1                  # load immediate, -1, into t9 
            sw $t9, ($t2)               # store -1 into widgetStatus[i] 
            b incrementLp               # jump to inc ptrs $ counter 

		jumpUpper: 
			#; Rework (> 108%)
            li $t9, 1                   # store 1 into t2
            sw $t9, ($t2)               # store 1 into widgetStatus[i] 
            b incrementLp               # jump to inc ptrs $ counter 
		
		#; Accept (92% <= Difference <= 108%)
        accept: 
            li $t9, 0 
            li $t3, 0                       # store 0 into t3
            sw $t3, ($t2)                   # store 0 into widgetStatus[i] 
  
        incrementLp:                                # inc counter and 3 ptrs
		    addu $t5, $t5, 1 				        # increment counter 
            addu $t0, $t0, 4                        # increment pointer to widgetMeasurements
            addu $t1, $t1, 4                        # increment pointer to widgetTargetSizes
            addu $t2, $t2, 4                        # increment pointer to widgetStatus
			bltu $t5, WIDGET_COUNT, checkWidgetLp 	# if counter < WIDGET_COUNT reloop 
	#; Output Widget Statuses
    
    la $t0, widgetStatus
    li $t1, 0                   # counter
    li $t2, 1                   # widget counter


	printLp:
		li $v0, SYSTEM_PRINT_STRING
		la $a0, messageWidgetHeader
		syscall 

		# print int 
        li $v0, SYSTEM_PRINT_INTEGER
        sw $t2, widgetNum
        lw $a0, widgetNum
        syscall 

        lw $t3, ($t0) 

        beq $t3, -1, rejectMsg 
        beq $t3, 1, reworkMsg 
        b acceptMsg 

        rejectMsg:
            # print str 
            li $v0, SYSTEM_PRINT_STRING
            la $a0, messageWidgetRejected
            syscall 
            b printLpDone

        reworkMsg:
            # print str 
            li $v0, SYSTEM_PRINT_STRING
            la $a0, messageWidgetRework
            syscall 
            b printLpDone
        
        acceptMsg:
            # print str 
            li $v0, SYSTEM_PRINT_STRING
            la $a0, messageWidgetAccepted
            syscall 
            b printLpDone

        printLpDone:
            addu $t1, $t1, 1
            addu $t2, $t2, 1
            addu $t0, $t0, 4 
            bltu $t1, WIDGET_COUNT, printLp


	#; Ends Program
	li $v0, SYSTEM_EXIT
	syscall
.end main