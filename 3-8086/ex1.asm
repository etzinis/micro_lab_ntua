


READ MACRO 
     MOV AH,08H
     INT 21H
ENDM

PRINT 	MACRO CHAR   	
	MOV  DL,CHAR   
	MOV  AH,02H  
	INT  21H
ENDM

PRINT_STR MACRO STRING		  
	  MOV DX,OFFSET STRING    
	  MOV AH,09H
	  INT 21H
ENDM 


DATA SEGMENT
	MSG1 DB 0AH, 0DH, "GIVE AN 8-BIT BINARY NUMBER: $"
	MSG2 DB 0AH, 0DH, "DECIMAL: $"
ENDS


STACK SEGMENT 
	DW 128 DUP<0>
ENDS



CODE SEGMENT
	ASSUME CS:CODE, DS:DATA, SS:STACK, ES:DATA

START:
	MOV AX,DATA
	MOV DS,AX
	MOV ES,AX

	PRINT_STR MSG1

	MOV BL,00H        ;THA APOTHIKEUSW TON BIN
	MOV CX,08H	      ;METRAW 8 LOOPS

IGNORE:
	READ
	CMP AL,51H       ;ASCII CODE FOR 'Q'
	JE FINISH
	CMP AL,30H	     ;IF LESS THAN '0' IGNORE
	JL IGNORE
	CMP AL,31H	     ;IF MORE THAN '1' IGNORE
	JG IGNORE
	SAL BL,01H	
	PUSH AX		     ;SAVE AL GT EPHREAZETAI APO TIN PRINT
	PRINT AL
	POP AX
	SUB AL,30H	     ;METAREPW TON ASCII CODE SE ARITHMO
	ADD BL,AL	     ;STO BL KRATAW TO INPUT
	LOOP IGNORE

	PRINT_STR MSG2

	MOV CH,00H
	MOV CL,00H


COUNT_HUN:             ;METRAW EKATONTADES
    CMP BL,64H
    JNA COUNT_DEC      ;NOT ABOVE GIATI THELW NA ELEKSW KAI TO CF
    INC CL
    SUB BL,64H
    JMP COUNT_HUN
    
COUNT_DEC:             ;METRAW DEKADES
    CMP BL,0AH
    JL SHOW
    INC CH
    SUB BL,0AH
    JMP COUNT_DEC
    
SHOW:                  ;METATREPW SE ASCII XARAKTHRES TO APOTELESMA
    ADD CL,30H         ;KAI TO EMFANIZW
	PRINT CL
	ADD CH,30H
	PRINT CH
	ADD BL,30H
	PRINT BL    

	JMP START

FINISH:
	ENDS




