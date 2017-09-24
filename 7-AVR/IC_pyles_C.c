#include <avr/io.h>

int main() {
	char a, b, c, d, e, F0, F1, F2, Fout, input;
	DDRA = 0x00;						//configure PORTA as input
	DDRC = 0xff;						//configure PORTC as output
	Fout =0;
	while(1) 
	{
		input = PINA; 					// input from PINA
		
		a = input%2; 					// use (input)mod2 to aqcuire the LDB
		input = input>>1; 				//shift right and repeat procedure to get all input
		b = input%2;
		input = input>>1;
		c = input%2;
		input = input>>1;
		d = input%2;
		input = input>>1;
		e = input%2;
		input = input>>1;
		
		F0 = ((a&b&c)|(c&d) |(d&e));
		if (F0==0) F0 = 1;						//complement fo 
		else F0=0;
		
		if (e==0) e=1;							//complement e 
		else e=0;
		F1 = ((a&b) | (c&d&e));
		
		F2 = (F0 |F1);
	
		Fout=(128*F0) |(64*F1) |(32*F2);  		//show F0 at PC7, F1 at PC6 and F2 at PC5
		PORTC = Fout; 							//output at PORTC
	}
	return 0;
 }
 
