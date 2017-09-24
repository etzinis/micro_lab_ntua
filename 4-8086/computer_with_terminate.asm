include 'lib4i.inc'



data segment
    num1 DW 0
    num2 DW 0
    NEWLINE DB 0AH,0DH,'$'
data ends


code_seg segment
    assume cs:code, ds:data, es:data 
    
        
main proc far    
start:
    mov ax,data
    mov ds,ax
    mov es,ax
               
ReadNum1:
    mov num1,0
    mov num2,0
    mov bl,0
    mov cx,3
    mov ah,0               ;read 3-digit number

ignore:
    READ 
    cmp al,'Q'             ;if Q terminate
    je finish
    cmp al,30h             ;if less than 0 ignore it
    jl ignore
    cmp al,39h
    jg checkCaps           ;if greater than 9 check if it is between A-F
    PRINT al
    sub al,30h             ;subtract 30h to get the correct number
save:
    mov ah,0
    sal num1,4 
    add num1,ax            ;multiply *16    
    loop ignore
      
    jmp getOp
    
save3:
    mov ah,0 
    add AL,0AH 
    sal num1,4
    
    add num1,ax            ;multiply *16    
    loop ignore
             
    jmp getOp
        
checkCaps:
    cmp al,'A'             ;if less than A ignore it
    jl ignore
    cmp al,'F'             ;if greater than F check if it is between a-f
    jg checkSmall
    PRINT al
    sub al,'A'             ;subtract 31h to get the correct number
    jmp save3  
     
     
checkSmall:
    cmp al,'a'
    jl ignore              ;if less than a ignore it                
    cmp al,'f'
    jg ignore              ;if greater than f ignore it
    PRINT al
    sub al,'a'             ;subtract 51h to get the right number
    jmp save3
             
             
getOp:
     READ
     cmp al,'Q'            ;if Q then terminate
     je finish
     cmp al,'+'
     je addition
     cmp al,'-'
     je subtraction
     jmp getOp
     
addition:
    PRINT al
    mov bl,al              ;in bl we keep the operation
    jmp ReadNum2
    
    
subtraction:
    PRINT al
    mov bl,al             
    
    
ReadNum2:
    mov cx,3               ;read the second 3-digit number

ignore2:
    READ 
    cmp al,'Q'             ;if Q terminate
    je finish
    cmp al,30h             ;if less than 0 ignore it
    jl ignore2
    cmp al,39h
    jg checkCaps2          ;if greater than 9 check if it is between A-F
    PRINT al
    sub al,30h             ;subtract 30h to get the correct number
save2: 
    MOV AH,0
    sal num2,4 
    add num2,ax            ;multiply *16    
    loop ignore2
    
    jmp wait1  
    
save4:
    mov ah,0 
    add AL,0AH 
    sal num2,4
    
    add num2,ax           ;multiply *16    
    loop ignore2
             
    jmp wait1  
        
checkCaps2:
    cmp al,'A'             ;if less than A ignore it
    jl ignore2
    cmp al,'F'             ;if greater than F check if it is between a-f
    jg checkSmall2
    PRINT al
    sub al,'A'             ;subtract 31h to get the correct number
    jmp save4 
     
     
checkSmall2:
    cmp al,'a'
    jl ignore2             ;if less than a ignore it                
    cmp al,'f'
    jg ignore2             ;if greater than f ignore it
    PRINT al
    sub al,'a'             ;subtract 51h to get the right number
    jmp save4

     
wait1: 
    READ
    cmp al,'Q'
    je finish
    cmp al,'='             ;wait until i read '='
    jne wait1      
    
    PRINT al               ;print '='
            
            
            
    cmp bl,'-'
    je subtr
    mov dx,num2            ;if operand is '+' then add them
   
    add num1,dx     
    PRINT_HEX num1
    PRINT '='
    PRINT_DEC num1
    PRINT_STR NEWLINE
    jmp start    

    
subtr:
    mov dx,num2
    cmp num1,dx             ;if second operand is greater then we have negative result
    jl negative  
    sub num1,dx    
    PRINT_HEX num1
    PRINT '='
    PRINT_DEC num1
    PRINT_STR NEWLINE
    jmp start
    
negative:
    mov dx,num1
    sub num2,dx
    PRINT '-'
    PRINT_HEX num2     
    PRINT '='
    PRINT '-'
    PRINT_DEC num2
    PRINT_STR NEWLINE
    jmp start

finish:
 
code_seg ends
END MAIN    
  




