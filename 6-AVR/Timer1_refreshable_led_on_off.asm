	.include "m16def.inc"

									;suxnotita tou EasyAVR6 = 8MHz ara auksisis tou TCNT1 = 8MHz/1024=7812.5Hz
	.equ Hvalue=high(49911) 		;thelw yperxeilish meta apo 2 sec ara 2*7812.5=15625 kyklous
	.equ Lvalue=low(49911) 			;ara arxikh timh 65536-15625 = 49911 = 0xC2F7
	.def flag=r17					;xrhsh flag gia na kserw an mpainw ksana stin routina eksuphrethshs ths diakophs
									;wste na anapsw ola ta LEDs tou PORTB (PA0 - PA7)
	
	.org 0x00 			 
	rjmp reset
	reti 			
	.org 0x04 			
	rjmp ISR1 
	reti							;routina eksupuretisis INT1
	.org 0x010 			
	rjmp TIMER1 					;routina eksupiretisis tis diakopis uperxeilisis tou timer1
	reti



reset: 
	ldi r26,low(RAMEND) 				;initialize stack pointer
	out SPL,r26
	ldi r26,high(RAMEND)
	out SPH,r26

	ser r26 				 
	out DDRB,r26 								;arxikopoioume to PORTB gia eksodo
	clr r26 				
	out DDRD,r26 								;arxikopoioume to PORTD gia eisodo
	out DDRA,r26								;arxikopoioume to PORTA gia eisodo

	ldi r23,( 1 << ISC11) | ( 1 << ISC10) 
	out MCUCR,r23                        		;diakoph INT1 se shma thetikhs akmhs              
	ldi r23,( 1 << INT1) 				   		;orizoume tin diakoph INT1
	out GICR,r23

	ldi r23 ,(1<<TOIE1) 				   		;energopoihsh diakophs yperxeilishs tou TCNT1
	out TIMSK ,r23 						   
	ldi r23 ,(1<<CS12) | (0<<CS11) | (1<<CS10)  ;syxnotita auksisis xronisth CLK/1024
	out TCCR1B ,r23 						   

	ldi flag,0
	sei 									    ;energopoihsh diakopwn


				;Main Program

loop1:
	in r27,PINA									
	andi r27,128 
	cpi r27,128
	breq ready									;elegxw an htan PA7=1
	rjmp loop1

ready:											
	in r27,PINA
	andi r27,128
	cpi r27,128									;kai me ta egine PA7=0
	breq ready
												;diladi an egine PUSH to PA7
	call ISR1									;kai tote exw interrupt
	 			
	rjmp loop1	

				;Routina eksuphrethshs INT1
ISR1:

check:	
	ldi r23 ,(1 << INTF1)		
	out GIFR ,r23			    ;set 0 the bit7 of GIFR
	ldi r24 , low(5)
	ldi r25 , high(5)			;load r25:r24 with 5
	rcall wait_msec			    ;delay = 5ms
	in r21,GIFR
	andi r21,128
	cpi r21,0                   ;if bit7 of GIFR==0 check again
	brne check

	ldi r23,Hvalue 			   ;Arxikopoihsh tou TCNT1
	out TCNT1H,r23 			   ;gia uperxeilisi meta apo 2sec
	ldi r23,Lvalue
	out TCNT1L,r23
	
	cpi flag,0
	breq first_time			;an flag=0 dn exei ksanaginei interrupt(sta 2 sec pou metraw)
	ldi flag,1
	ldi r26,255
	out PORTB,r26
	
	ldi r24,low(500)		;r25:r24 = 200
	ldi r25,high(500) 
	rcall wait_msec			;delay 0.5 sec
	
first_time:					;prwth fora pou egine interrupt (sta 2 sec pou metraw kathe fora)
	ldi flag,1				;flag = 1 giati an ksanaexw interrupt tha xreiastei na anapsw ola ta LEDs tou PORTB
	ldi r26,1
	out PORTB,r26 			;anamma tou PB0
	reti
	



		;routina eksupiretisis yperxeilishs xronisth
TIMER1:
	ldi flag,0			;epanafora tou flag sto 0
	ldi r26,0 			
	out PORTB,r26		;mhdenismos tou PB0
	reti


	
			;dealay routines		
wait_usec:
	sbiw r24,1			;2 circle (0.250 μsec)
	nop					;1 cilrcle (0.125 μsec)
	nop					
	nop					
	nop					
	brne wait_usec		;1 or 2 circles (0.125 or 0.250 μsec)
	ret					;4 circles (0.500 μsec)

wait_msec:
	push r24			;2 cirlces (0.250 μsec)
	push r25			
	ldi r24,low(998)	;1 cirlce
	ldi r25,high(998) 
	rcall wait_usec		;3 circles (0.375 μsec)
	pop r25				;2 cirlces
	pop r24 
	sbiw r24,1			;2 circles 
	brne wait_msec		;1 or 2 circles 
	ret					;4 circles

	