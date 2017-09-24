.include "m16def.inc"

main:
	ldi r24,LOW(RAMEND)		;initialize stack pointer
	out SPL,r24
	ldi r24,HIGH(RAMEND)
	out SPH,r24
	ser r24					;r24 = 11111111b
	out DDRB,r24			;initialize PORTB for output
	clr r24					;r24 = 0
	out DDRA,r24			;initialize PORTA for input
	ldi r26,1				;start from the 'most' right LED

left:						;LED moving left
	in r27,PINA				;PINA is the register we use to read the input from PORTA
	out PORTB,r26			;show the led in PORTB
	ldi r24 , low(500)		;r25:r24 = 500
    ldi r25 , high(500)		;delay 0,5sec 
	rcall wait_msec
	andi r27,0x80
	cpi r27,128				;check if PA7 is pushed
	breq left				;if it is don't move the LED
	lsl r26					;logical shift left
	cpi r26,128				;check if the LED reached the (left) end
	breq right				;if so start moving it to right
	jmp left				;else keep moving left


right:					    ;LED moving left
	in r27,PINA			
	out PORTB,r26			;show the led in PORTB
	ldi r24,low(500)  
    ldi r25,high(500)		;delay 0,5sec 
	rcall wait_msec
	andi r27,0x80
	cpi r27,128				;check if PA7 is pushed
	breq right			
	lsr r26					;logical shift right
	cpi r26,1				;check if the LED reached the (right) end
	breq left				;if so start moving it to left
	jmp right				;else keep moving right

wait_usec:					;delay r25:r24 μsec
	sbiw r24,1				
	nop 
	nop 
	nop 
	nop 
	brne wait_usec			 
	ret						 

wait_msec:					;delay r25:r24 msec
	push r24				 
	push r25 
	ldi r24,low(998)		 
	ldi r25,high(998)		 
	rcall wait_usec			 
	pop r25					 
	pop r24 
	sbiw r24,1 
	brne wait_msec			 
	ret

