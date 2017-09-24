
.include "m16def.inc"

.def a0=r17
.def a1=r18
.def a2=r19
.def a3=r20
.def a4=r21
.def a5=r22
.def a6=r23
.def a7=r24
.def output=r25

		
		clr r26
		out DDRA,r26		;set PORTA as input
		out DDRC,r26		;set PORTC as input
		ser r26
		out DDRB,r26		;set PORTB as output
	
start: 	in r26,PINA
		clr output
		mov a0,r26			;get PA0-PA7
		andi a0,0x01
		
		mov a1,r26
		andi a1,0x02
		lsr a1
		
		mov a2,r26
		andi a2,0x04
		lsr a2
		lsr a2
		
		mov a3,r26
		andi a3,0x08
		lsr a3
		lsr a3
		lsr a3
		
		mov a4,r26
		andi a4,0x10
		lsr a4
		lsr a4
		lsr a4
		lsr a4
		
		mov a5,r26
		andi a5,0x20
		cpi a5,0x20
		brne next6
		ldi a5,1
		
next6:	mov a6,r26
		andi a6,0x40
		cpi a6,0x40
		brne next7
		ldi a6,1
		
next7:	mov a7,r26
		andi a7,0x80
		cpi a7,0x80
		brne next
		ldi a7,1
		
next:	eor a0,a1 		;a0= PA0 XOR PA1
		or a2,a3 	 	;a2=PA2 OR PA3
		
		cpi a2,0		;if (PA2 OR PA3 ) == 1 set PB1=1
		breq gate5
		ldi r26,0x02		
		add output,r26
		
gate5:	and a2,a0    
		cpi a2,0		;if ((PA2 OR PA3) AND (PA0 XOR PA1))==1 set PB0=1
		breq gate3
		ldi r26,0x01
		add output,r26
		
gate3:	or a4,a5
		cpi a4,0  		;if (PA4 OR PA5)==0 then (PA4 NOR PA5)==1 so set PB2=1
		brne gate4
		ldi r26,0x04
		add output,r26

gate4:	eor a6,a7 
		cpi a6,0		;if (PA6 XOR PA7)==0 then (PA6 NXOR PA7)==1 so set PB3=1
		brne show
		ldi r26,0x08
		add output,r26
		
show:	in r26,PINC
		eor output,r26 ; output = output XOR r26 ,to get the compliment of LEDS PB0-PB7 if the equivalent PUSH BUTTON PC0-PC7 is pushed   
		out PORTB,outpu
		jmp start
		
		
		