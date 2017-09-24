
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
	ser r24
    out DDRB,r24	; PORTB output
    ldi r24 ,(1 << PC7) | (1 << PC6) | (1 << PC5) | (1 << PC4)
    out DDRC ,r24	; 4x4 keypad output initiallization
	ldi r24,0x00		
    ldi r25,0x00
    ldi r26 ,low(_tmp_)		;r26:r27 makes thw register X
    ldi r27 ,high(_tmp_)
    st X+ ,r24				;store in the address of X zero
    st X ,r25
locked:
    
    ldi r24, 0x14			;r24 has the bouncing time lets say 20ms
    rcall scan_keypad_rising_edge	;read the first num from keyb
	rcall keypad_to_ascii	;turn it to ascii and get the result in r24
    cpi r24, '0'			;r24 has the result, if first number == 0
    brne locked				;else check again


loop2:
    ldi r24, 0x14	
    rcall scan_keypad_rising_edge
	rcall keypad_to_ascii
	cpi r24,'0'
	breq loop2
	cpi r24,0
	breq loop2
    cpi r24, '4'			;if the second number is 4 then unlock
    brne locked
    rjmp open

open:
    ldi r24,0xff			;open leds of b for 3 secs
    out PORTB, r24
    ldi r24,low(3000)
    ldi r25,high(3000)
    rcall wait_msec
    ldi r24,0x00
    out PORTB, r24			;turn leds off
    rjmp locked				;continuous functionality


.org 0x300
rjmp start

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
  

;delay routines
wait_usec:
	sbiw r24 ,1						;2 circle (0.250 micro sec)
	nop								;1 cilrcle (0.125 micro sec)
	nop					
	nop					
	nop					
	brne wait_usec					;1 or 2 circles (0.125 or 0.250 micro sec)
	ret								;4 circles (0.500 mic sec)

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
	
keypad_to_ascii:		;routine to tranduce the result in r24 to an ascii code in order to compare it afterwards
		movw r26 ,r24 
		ldi r24 ,'*'
		sbrc r26 ,0
		ret
		ldi r24 ,'0'
		sbrc r26 ,1
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
		ldi r24 ,'4' 
		sbrc r27 ,0
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
		clr r24
		ret							
