
.include "m16def.inc"

.org 0x0
rjmp reset
.org 0x4
rjmp ISR1
reti

			
reset:                
	ldi r26,low(RAMEND)						;initialize stack pointer
	out SPL,r26
	ldi r26,high(RAMEND)
	out SPH,r26

	ser r26 
	out DDRA,r26							;initialize PORT A for output
	out DDRB,r26							;initialize PORT B for output
	clr r26									;clear time counter and 
	out DDRD,r26							;initialize PORT D for input
	clr r27
	
	ldi r22,( 1 << ISC11) | ( 1 << ISC10)   ;make INT1 happen at  
	out MCUCR,r22                           ;the rising edge of the signal              
	ldi r22,( 1 << INT1)				    ;set INT1 in interrupt mask
	out GICR,r22
	sei									    ;activate interrupts


loop1:          
	out PORTB,r26					;show the output of the counter
	ldi r24,low(200)				;r25:r24 = 200
	ldi r25,high(200) 
	rcall wait_msec					;delay 0,2 sec
	inc r26							;increase the counter
	rjmp loop1


ISR1:
check:
	ldi r21 ,(1 << INTF1)		
	out GIFR ,r21			       ;set 0 the bit7 of GIFR
	ldi r24 , low(5)
	ldi r25 , high(5)			   ;load r25:r24 with 5
	rcall wait_msec			  	   ;delay = 5ms
	in r21,GIFR
	andi r21,128
	cpi r21,0              	       ;if bit7 of GIFR==0 check again
	brne check

	cli								;deactivate interrupts
	push r26						;save r26 and SREG
	in r26,SREG						
	push r26
	
	in r28,PIND
	andi r28,128
	cpi r28,128
	brne not_incr 
	inc r27							;increase the interrupt counter
not_incr:
	out PORTA,r27	
	pop r26
	out SREG,r26					
	pop r26							;pop back r26,SREG
	sei								;activate interrupts
	reti 

				;delay routines
wait_usec:
	sbiw r24,1						;2 circle (0.250 μsec)
	nop								;1 cilrcle (0.125 μsec)
	nop					
	nop					
	nop					
	brne wait_usec					;1 or 2 circles (0.125 or 0.250 μsec)
	ret								;4 circles (0.500 μsec)

wait_msec:
	push r24						;2 cirlces (0.250 μsec)
	push r25			
	ldi r24,low(998)				;1 cirlce
	ldi r25,high(998) 
	rcall wait_usec					;3 circles (0.375 μsec)
	pop r25							;2 cirlces
	pop r24 
	sbiw r24 , 1					;2 circles 
	brne wait_msec					;1 or 2 circles 
	ret								;4 circles