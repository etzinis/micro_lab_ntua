.include "m16def.inc"

.def temp=r17
.def cnt=r18
.def loops=r19
.def init=r23
.def i=r22
.org 0x0
rjmp reset
.org 0x2
rjmp ISR0
		
reset:
	ldi r24,low(RAMEND)        					;initialize stack pointer
	out SPL,r24
	ldi r24,high(RAMEND)
	out SPH,r24
	clr r26
	out DDRA,r26
	ser r26
	out DDRB , r26								;initialize PORTB as output
	out DDRC,r26								 ;initialize PORTC as output	
	clr r26										;initialize the counter
	ldi r24 ,( 1 << ISC01) | ( 1 << ISC00)	   	;make INT0 happen at  
	out MCUCR , r24							   	;the rising edge of the signal
	ldi r24 ,( 1 << INT0)						;set INT0 in interrupt mask
	out GICR , r24
	sei											;enable interrupt
		
loop1: 	
	out PORTB , r26								;show the counter at PORTA
	ldi r24 , low(100)							;load r25:r24 with 100
	ldi r25 , high(100)							;delay = 100ms
	rcall wait_msec
	inc r26										;increase counter
	rjmp loop1									;repeat
		

ISR0: 		
	ldi r24 ,(1 << INTF0)		
	out GIFR ,r24								 ;set 0 the bit6 of GIFR
	ldi r24 , low(5)
	ldi r25 , high(5)						 	 ;load r25:r24 with 5000
	rcall wait_msec								 ;delay = 5ms
	in r21,GIFR
	andi r21,0x40
	cpi r21,0                                    ;if bit6 of GIFR==0 check again
	brne ISR0
	cli
	push r26
	in r26,PINA									;save the content of r26 and SREG
	mov init,r26
	in r26,SREG
	push r26        
	ldi i,1 									 
	ldi cnt,0									 ;initialize counter of 0
	ldi loops,0									 ;initialize number of loops,must be done 8 loops to check all the bits		
counter:
	mov temp,init                                
	and temp,i
	cp temp,i									;check if the i-th bit of the number of PORTA == 1
	brne dontinc
	inc cnt										;if so increase the counter
dontinc:
	inc loops									;increase loops
	lsl i										;shift i left
	cpi loops,8
	brlo counter								;if loops are less than 8 ,loop again
	ldi r20,0x00
	cpi cnt,0
	breq ok										;if counter is 0 don't turn any led on								
seton:	lsl r20										;if not turn on the appropriate leds 
	inc r20
	dec cnt
	cpi cnt,0
	brne seton
ok:	out PORTC,r20
	ldi r24 , low(998)
	ldi r25 , high(998)
	rcall wait_msec								;delay = 1s
	pop r26
	out SREG,r26
	pop r26
	sei
	reti
		
wait_usec:
	sbiw r24 ,1									;2 cycle (0.250 µsec)
	nop											;1 cycle (0.125 µsec)
	nop					
	nop					
	nop					
	brne wait_usec								;1 or 2 cycles (0.125 or 0.250 µsec)
	ret											;4 cycles (0.500 µsec)

wait_msec:
	push r24									;2 cycles (0.250 µsec)
	push r25			
	ldi r24 , low(998)							;1 cycles
	ldi r25 , high(998) 
	rcall wait_usec								;3 cycles (0.375 µsec)
	pop r25										;2 cycles
	pop r24 
	sbiw r24 , 1								;2 cycles 
	brne wait_msec								;1 or 2 cycles 
	ret											;4 cycles		
