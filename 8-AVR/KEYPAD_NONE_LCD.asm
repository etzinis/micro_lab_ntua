;
; AssemblerApplication1.asm
;
; Created: 5/12/2015 5:25:44 µµ
; Author : rafail 17
;

.dseg
_tmp_: .byte 2

.cseg
.include "m16def.inc"
.org 0x00
rjmp start

start:
	ldi r26,low(RAMEND)						;initialize stack pointer
	out SPL,r26
	ldi r26,high(RAMEND)
	out SPH,r26
    ldi r24 ,(1 << PC7) | (1 << PC6) | (1 << PC5) | (1 << PC4)
   	out DDRC ,r24	; 4x4 keypad output initiallization
   	ldi r24,0x00		
   	ldi r25,0x00
	ldi r26 ,low(_tmp_)		;r26:r27 makes thw register X
    ldi r27 ,high(_tmp_)
	st X+ ,r24				;store in the address of X zero
    st X ,r25
	ser r24
	out DDRD ,r24
	rcall lcd_init			;initialize the screen
	ldi r24,'N'
	rcall lcd_data
	ldi r24,'O'
	rcall lcd_data
	ldi r24,'N'
	rcall lcd_data
	ldi r24,'E'
	rcall lcd_data

reading:
    
    ldi r24, 0x14			;r24 has the bouncing time lets say 20ms
    rcall scan_keypad_rising_edge	;read the first num from keyb
	rcall keypad_to_ascii		;turn it to ascii and get the result in r24
	cpi r24, 0x00			;r24 has the result, if r24==0 then we have no change
   	breq reading			;then check again // else we have to change the value that we are showing 
							;(r24 has the character that we want)
	mov r27,r24
	ldi r24 ,0x01 			; clear display
	rcall lcd_command

	ldi r24 ,low(1530)
	ldi r25 ,high(1530)
	rcall wait_usec
	mov r24,r27
	rcall lcd_data			;r24 has the proper data value
    rjmp reading			;continuous functionality
	
;============================================LCD ROUTINES========================================================

write_2_nibbles:
	push r24 		; st???e? ta 4 MSB
	in r25 ,PIND 	; d?a?????ta? ta 4 LSB ?a? ta ?a?ast?????µe
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
	ldi r24 ,0x30 	; e?t??? µet??as?? se 8 bit mode
	out PORTD ,r24 	; epe?d? de? µp????µe ?a e?µaste ???a???
	sbi PORTD ,PD3 	; ??a t? d?aµ??f?s? e?s?d?? t?? e?e??t?
	cbi PORTD ,PD3 	; t?? ??????, ? e?t??? ap?st???eta? d?? f????
	ldi r24 ,39
	ldi r25 ,0 		; e?? ? e?e??t?? t?? ?????? ???s?eta? se 8-bit mode
	rcall wait_usec ; de? ?a s?µ?e? t?p?ta, a??? a? ? e?e??t?? ??e? d?aµ??f?s?
					; e?s?d?? 4 bit ?a µeta?e? se d?aµ??f?s? 8 bit
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
	
ascii_to_lcd:	;result in ascii in r24	
		ldi r25, 0b00101010
		cpi r24 ,'*'
		breq exit_show_char
		
		ldi r25, 0b00100011
		cpi r24 ,'#'
		breq exit_show_char
		
		ldi r25, 0b01000100
		cpi r24 ,'D'
		breq exit_show_char
		
		ldi r25, 0b00110111 
		cpi r24 ,'7'
		breq exit_show_char
		
		ldi r25, 0b00111000
		cpi r24 ,'8'
		breq exit_show_char
		
		ldi r25, 0b00111001
		cpi r24 ,'9'
		breq exit_show_char
		
		ldi r25, 0b01000011
		cpi r24 ,'C'
		breq exit_show_char
		
		ldi r25, 0b00110101
		cpi r24 ,'5'
		breq exit_show_char
		
		ldi r25, 0b00110110
		cpi r24 ,'6'
		breq exit_show_char
		
		ldi r25, 0b01000010
		cpi r24 ,'B'
		breq exit_show_char
		
		ldi r25, 0b00110001
		cpi r24 ,'1'
		breq exit_show_char
		
		ldi r25, 0b00110010
		cpi r24 ,'2'
		breq exit_show_char
		
		ldi r25, 0b00110011
		cpi r24 ,'3'
		breq exit_show_char
		
		ldi r25, 0b01000001
		cpi r24 ,'A'
		breq exit_show_char
		
		ldi r25, 0b00110000
		cpi r24 ,'0'
		breq exit_show_char
		
		ldi r25, 0b00110100
		cpi r24 ,'4' 
		breq exit_show_char
		
		ldi r25, 0b00000000
exit_show_char:
		ret	

;show_char:
	
	

;=================================================================================================================

;======================================KEYPAD===================================================================
scan_row:
	;nop
	ldi r25 ,0x08	
back_: 
	lsl r25		
	dec r24		
	brne back_
	out PORTC ,r25	
	nop
	nop				
	in r24 ,PINC
	andi r24 ,0x0f	
	ret				
scan_keypad:
	;nop
	ldi r24 ,0x01	
	rcall scan_row
	swap r24		
	mov r27 ,r24	
	ldi r24 ,0x02	
	rcall scan_row
	add r27 ,r24	
	ldi r24 ,0x03	
	rcall scan_row
	swap r24		
	mov r26 ,r24	
	ldi r24 ,0x04	
	rcall scan_row
	add r26 ,r24	
	movw r24 ,r26	
	ret
scan_keypad_rising_edge:
	;nop
	mov r22 ,r24		
	rcall scan_keypad	
	push r24			
	push r25
	mov r24 ,r22		
	ldi r25 ,0			
	rcall wait_msec
	rcall scan_keypad	
	pop r23				
	pop r22				
	and r24 ,r22
	and r25 ,r23
	ldi r26 ,low(_tmp_)	
	ldi r27 ,high(_tmp_) 
	ld r23 ,X+
	ld r22 ,X
	st X ,r24			
	st -X ,r25			
	com r23
	com r22				
	and r24 ,r22
	and r25 ,r23
	ret
	
keypad_to_ascii:		;routine to tranduce the result in r24 to an ascii code in order to compare it afterwards
		movw r26 ,r24 
		ldi r24 ,'*'
		sbrc r26 ,0
		ret
		
		ldi r24 ,'#'
		sbrc r26 ,2
		ret
		ldi r24 ,'D'
		sbrc r26 ,3 
		ret 
		ldi r24 ,'7'
		sbrc r26 ,4
		ret
		ldi r24 ,'8'
		sbrc r26 ,5
		ret
		ldi r24 ,'9'
		sbrc r26 ,6
		ret
		ldi r24 ,'C'
		sbrc r26 ,7
		ret
		
		ldi r24 ,'5'
		sbrc r27 ,1
		ret
		ldi r24 ,'6'
		sbrc r27 ,2
		ret
		ldi r24 ,'B'
		sbrc r27 ,3
		ret
		ldi r24 ,'1'
		sbrc r27 ,4
		ret
		ldi r24 ,'2'
		sbrc r27 ,5
		ret
		ldi r24 ,'3'
		sbrc r27 ,6
		ret
		ldi r24 ,'A'
		sbrc r27 ,7
		ret
		ldi r24 ,'0'
		sbrc r26 ,1
		ret
		ldi r24 ,'4' 
		sbrc r27 ,0
		ret
		clr r24
		ret	
  
;===============================DELAY ROUTINES ==========================================================================
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
	
	


;===============================================================================				
