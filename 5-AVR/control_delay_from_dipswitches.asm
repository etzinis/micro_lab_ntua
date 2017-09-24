

.include "m16def.inc"


	ldi r24,low(RAMEND)        ;initialize stack pointer
	out SPL,r24
	ldi r24,high(RAMEND)
	out SPH,r24
	ser r26 
	out DDRA,r26			 ;use PORTA for output
	clr r26
	out DDRB,r26			 ;use PORTB for input

flash: 
	in r26,PINB				;read from PORTB (for light-on)
	andi r26,0b11110000		;mask the B4-B7 bits - for light-on
	lsr r26					;ta fernw sta B0-B3
	lsr r26
	lsr r26
	lsr r26
	ldi r27,2				
	mul r26,r27				;2*x 
	inc r26					;2*x+1
	ldi r27,50 
	mul r26,r27				;(2x+1)*50  -  r1:r0 <- r26*r27
	mov r25,r1				;store the result in r25:r24
    mov r24,r0				;the correct delay
	ser r26					;light-on all the LEDs
	out PORTA,r26
	rcall wait_msec			;light-on delay
					
	in r26,PINB				;read from PORTB (for light-off)
	andi r26,0b00001111		;mask the B0-B3bits - for light-off
	ldi r27,2				
	mul r26,r27				;2*x 
	inc r26					;2*x+1
	ldi r27,50				;(2x+1)*50
	mul r26,r27
	mov r25,r1				
	mov r24,r0 
	clr r26					;light-off all the LEDs
	out PORTA,r26
	rcall wait_msec			;light-off delay
	jmp flash				;continious functionality


wait_usec:					;delay r25:r24 usec
sbiw r24 ,1				
nop 
nop
nop
nop
brne wait_usec 
ret 

wait_msec:					 ;delay r25:r24 msec
push r24
push r25
ldi r24 , low(998) 
ldi r25 , high(998) 
rcall wait_usec 
pop r25
pop r24 
sbiw r24,1 
brne wait_msec 
ret 

