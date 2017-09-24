﻿.include "m16def.inc"

.def hundreds=r17
.def decades=r18
.def units=r19
.def counter=r20


		ldi r26,low(RAMEND)						;initialize stack pointer
		out SPL,r26
		ldi r26,high(RAMEND)
		out SPH,r26
		clr r26
		out DDRB,r26 	;set PINB as input
		ldi r24,0xfc
		out DDRD ,r24	;set PORTD as output
	    call lcd_init	;initialize the lcd screen
start:	
		in r26,PINB		;read the input
		mov r23,r26
backagain:
		ldi r24 ,0x01 			; clear display
		rcall lcd_command
		ldi r24 ,low(1530)
		ldi r25 ,high(1530)
		rcall wait_usec
		mov r28,r26  	;r28 has the value of the input
		ldi counter,8
loopa:	
		mov r30,r28				;loop to show the binary number we read to the lcd screen
		andi r30,0x80
		cpi r30,0x80
		brne not_equal
		ldi r24,'1'
		jmp show
not_equal:
		ldi r24,'0'
show:	call lcd_data
		lsl r28
		dec counter
		cpi counter,0
		brne loopa
		
		ldi r24,'='		;show '=' to the lcd screen
		call lcd_data
		
		mov r27,r26		
		andi r26,0x80
		cpi r26,0x80  	;check if the value we read is negative(check if the 7-bit is equal to 1)
		brne positive
		ldi r24,'-'		;if so get the compliment of 2 of the value and show '-' to the lcd screen
		call lcd_data
		neg r27
		jmp next
positive:
		ldi r24,'+'		;if not just show '+' to the lcd screen
		call lcd_data
next:					;get the bcd value of the binary number we read 
		ldi hundreds,0
		ldi decades,0
		ldi units,0
		cpi r27,100
		brlo hundreds_ok
		ldi hundreds,1
		subi r27,100
hundreds_ok:	
		cpi r27,10
		brlo decades_ok
		inc decades
		subi r27,10
		jmp hundreds_ok
decades_ok: 
		mov units,r27
		
		ldi r21,0x30
		add hundreds,r21	;show the number of hundreds to the lcd screen
		mov r24,hundreds
		call lcd_data
		
		ldi r21,0x30
		add decades,r21	;show the number of decades to the lcd screen
		mov r24,decades
		call lcd_data
		
		ldi r21,0x30
		add units,r21		;show the number of units to the lcd screen
		mov r24,units
		call lcd_data
wait:	in r26,PINB
		cp r26,r23
		breq wait
		mov r23,r26
		jmp backagain			;continuous functionality



write_2_nibbles:
	push r24 		; st???e? ta 4 MSB
	in r25 ,PIND 	; d?aß????ta? ta 4 LSB ?a? ta ?a?ast?????µe
	andi r25 ,0x0f 	; ??a ?a µ?? ?a??s??µe t?? ?p??a p??????µe?? ?at?stas?
	andi r24 ,0xf0 	; ap?µ??????ta? ta 4 MSB ?a?
	add r24 ,r25 	; s??d?????ta? µe ta p???p?????ta 4 LSB
	out PORTD ,r24 	; ?a? d????ta? st?? ???d?
	sbi PORTD ,PD3 	; d?µ?????e?ta? pa?µ?? ?nable st?? a???d??t? PD3
	cbi PORTD ,PD3 	; PD3=1 ?a? µet? PD3=0
	pop r24 		; st???e? ta 4 LSB. ??a?t?ta? t? byte.
	swap r24 		; e?a???ss??ta? ta 4 MSB µe ta 4 LSB
	andi r24 ,0xf0 	; p?? µe t?? se??? t??? ap?st?????ta?
	add r24 ,r25
	out PORTD ,r24
	sbi PORTD ,PD3 	; ???? pa?µ?? ?nable
	cbi PORTD ,PD3
	ret
	
	
lcd_data:
	sbi PORTD ,PD2 			; ep????? t?? ?ata????t? ded?µ???? (PD2=1)
	rcall write_2_nibbles 	; ap?st??? t?? byte
	ldi r24 ,43 			; a?aµ??? 43µsec µ???? ?a ?????????e? ? ????
	ldi r25 ,0 				; t?? ded?µ???? ap? t?? e?e??t? t?? lcd
	rcall wait_usec
	ret	
	
	
lcd_command:
	cbi PORTD ,PD2 			; ep????? t?? ?ata????t? e?t???? (PD2=1)
	rcall write_2_nibbles 	; ap?st??? t?? e?t???? ?a? a?aµ??? 39µsec
	ldi r24 ,39 			; ??a t?? ????????s? t?? e?t??es?? t?? ap? t?? e?e??t? t?? lcd.
	ldi r25 ,0 				; S??.: ?p?????? d?? e?t????, ?? clear display ?a? return home,
	rcall wait_usec 		; p?? apa?t??? s?µa?t??? µe?a??te?? ??????? d??st?µa.
	ret	
	
	
lcd_init:
	ldi r24 ,40 	; ?ta? ? e?e??t?? t?? lcd t??f?d?te?ta? µe
	ldi r25 ,0 		; ?e?µa e?te?e? t?? d??? t?? a?????p???s?.
	rcall wait_msec ; ??aµ??? 40 msec µ???? a?t? ?a ?????????e?.
	ldi r24 ,0x30 	; e?t??? µet?ßas?? se 8 bit mode
	out PORTD ,r24 	; epe?d? de? µp????µe ?a e?µaste ß?ßa???
	sbi PORTD ,PD3 	; ??a t? d?aµ??f?s? e?s?d?? t?? e?e??t?
	cbi PORTD ,PD3 	; t?? ??????, ? e?t??? ap?st???eta? d?? f????
	ldi r24 ,39
	ldi r25 ,0 		; e?? ? e?e??t?? t?? ?????? ß??s?eta? se 8-bit mode
	rcall wait_usec ; de? ?a s?µße? t?p?ta, a??? a? ? e?e??t?? ??e? d?aµ??f?s?
					; e?s?d?? 4 bit ?a µetaße? se d?aµ??f?s? 8 bit
	ldi r24 ,0x30
	out PORTD ,r24
	sbi PORTD ,PD3
	cbi PORTD ,PD3
	ldi r24 ,39
	ldi r25 ,0
	rcall wait_usec
	ldi r24 ,0x20 		; a??a?? se 4-bit mode
	out PORTD ,r24
	sbi PORTD ,PD3
	cbi PORTD ,PD3
	ldi r24 ,39
	ldi r25 ,0
	rcall wait_usec
	ldi r24 ,0x28 		; ep????? ?a?a?t???? µe?????? 5x8 ?????d??
	rcall lcd_command 	; ?a? eµf???s? d?? ??aµµ?? st?? ?????
	ldi r24 ,0x0c 		; e?e???p???s? t?? ??????, ap?????? t?? ???s??a
	rcall lcd_command
	ldi r24 ,0x01 		; ?a?a??sµ?? t?? ??????
	rcall lcd_command
	ldi r24 ,low(1530)
	ldi r25 ,high(1530)
	rcall wait_usec
	ldi r24 ,0x06 		; e?e???p???s? a?t?µat?? a???s?? ?at? 1 t?? d?e????s??
	rcall lcd_command 	; p?? e??a? ap????e?µ??? st?? µet??t? d?e????se?? ?a?
						; ape?e???p???s? t?? ???s??s?? ????????? t?? ??????
	ret	
	
;delay routines
wait_usec:
	sbiw r24 ,1						;2 cycle (0.250 micro sec)
	nop								;1 cycle (0.125 micro sec)
	nop					
	nop					
	nop					
	brne wait_usec					;1 or 2 cycles (0.125 or 0.250 micro sec)
	ret								;4 cycles (0.500 micro sec)

wait_msec:
	push r24						
	push r25			
	ldi r24 , low(998)				
	ldi r25 , high(998) 
	rcall wait_usec					
	pop r25							
	pop r24 
	sbiw r24 , 1					
	brne wait_msec					
	ret	
	
