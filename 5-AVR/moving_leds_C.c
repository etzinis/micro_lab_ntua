#include <avr/io.h> 

unsigned char ror(unsigned char num,unsigned char n)     //function to shift a number n spots right with curry
{
	 unsigned char i,temp,j;
	 for(j=0;j<n;j++){
	 temp=num;
	 i=(temp & 0x01);
	num=num>>1;
	if (i==0x01) num=num+ 0x80;
	 }	
	return num;
}

unsigned char rol(unsigned char num,unsigned char n)	//function to shift a number n spots left with curry
{
	 unsigned char i,temp,j;
	  for(j=0;j<n;j++){
	 temp=num;
	 i=(temp & 0x80);
	num=num<<1;
	if(i==0x80) num=num+ 0x01;
	  }	
	return num;
}



int main(void)
{
unsigned char i,temp;	
DDRB=0xFF;	//set PortD as input
DDRD=0x00;	//set PortB as output
PORTB=0x80;	//turn on led7
temp=0x80;	//initialize temp which shows the led which is on
while(1)	
{
	i=PIND;							//check input
	if ((i & 0x10)==0x10) 			//check if bit4 of PortD is 1
	{		
		temp=0x80;					
		PORTB=temp;					//move led to his initial position
			
	}
	else if ((i & 0x08)==0x08)		//check if bit3 of PortD is 1
	{	
		temp=rol(temp,2);			
    	PORTB=temp;					//move led 2 spots left
	}
	else if ((i & 0x04)==0x04)		//check if bit2 of PortD is 1
	{	
		temp=ror(temp,2);			//move led 2 spots right
		PORTB=temp;
	}
	else if ((i & 0x02)==0x02)		//check if bit1 of PortD is 1
	{
		temp=rol(temp,1);			//move led 1 spot left
    	PORTB=temp;
	}
	 else if ((i & 0x01)==0x01)		//check if bit0 of PortD is 1
	 {
		 temp=ror(temp,1);			////move led 1 spot right
		 PORTB=temp;
	 }
}	

return 1;
	
}