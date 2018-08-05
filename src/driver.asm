; *******************************************************************
; *		
; *		�������� ������� �������. ��03-621
; *		2009-2010��.
; *		
; *******************************************************************

#include <p16F887.inc>
    __CONFIG    _CONFIG1, _LVP_OFF & _FCMEN_OFF & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_ON & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
    __CONFIG    _CONFIG2, _WRT_OFF & _BOR21V


    cblock 0x20
		RS232Received			; �������� �� RS232 ���
		
		Delay				; 
		Delay1				; ��������� ��������
		Delay2				;

		Barriers			; ����������� �� ������ �������� �����������
		LineCount			; ���������� ���������������� ����� ��� ���������

		LineLeft			; ������� �������� c �������� ������ �������� ������� �����  
		LineMiddleLeft		        ; ������� �������� c �������� ������ �������� ������� �����  
		LineMiddleRight			; ������� �������� c �������� ������� �������� ������� �����  
		LineRight			; ������� �������� c �������� ������� �������� ������� �����  

		LineState			; 4 ������� ���� - ������ �����, 4 ������� �����, ����������� ����
		CurrentValue			; ������� ��������, ������������ � ������������ ��������� ������ ���
								; ���������� �������/���������� �����!!!!
								; ������������ ��� �������� ������ �� ����� ����� ��������� ���
		VoltageTreshhold		; ���. ��������� ���������� ��� ����� � �����

		ButtonPushCounter		; ��������� �������� ��������� ��� "����"
		StableStateCounter		; ��������� �������� ��������� ��� "����"

		NextSongNumber			; ����� ��������� ��� ��������������� ������� 
		CurrentSongNumber		; ����� ������� ��� ���������������� ������� (� ������)
		SpaceOptions			; ��������� ����������� ������������

		CycleCounterL			; ������� ������ �������0. ������� �����
		CycleCounterH			; ������� ������ �������0. ������� �����

		MessageStart			; b'11111111'- ������ ���� � �� ��, �������������
		MessageParams			; b'11xxxxxx'- <7:6> - ������ b'11', <5:2> - ����� ���������, <1:0> - ��������
		Byte0				; �������� ������ � ������ ����� 
		Byte1				; �������� 16 ���� ������ �� ���
		Byte2				;
		Byte3				; 
		Byte4				;
		Byte5				
		Byte6				;
		Byte7				;
		Byte8				;
		Byte9				;
		Byte10				;
		Byte11				;
		Byte12				;
		Byte13				;
		Byte14				;
		Byte15				;
		MessageEnd			; '#' - ������ ���� � �� ��, ����� ��������
		MessageLength			; ����� ��������� ��� ��������� �� �����������
		

		LineLeftDebug
		LineMiddleLeftDebug
		LineMiddleRightDebug
		LineRightDebug

    endc

    org 0
    
Start:

; *******************************************************************
; *		��������� ��������� ������ �����-������
; *******************************************************************
;
;--------------  Bank 1 --------------
    bsf       	STATUS,RP0		; ����� Register Bank 1 

; ���� A 
    movlw		b'00001111'
    movwf		TRISA         	; RA0, RA1, RA2, RA3 - ����� ���. RA6, RA7 - �����

; ���� B
    movlw		b'00011111'
    movwf   	TRISB			; RB0, RB1, RB2, RB3, RB4 - �����, ������

; ���� C
    movlw		b'10000000'
    movwf   	TRISC			; RC7 - ���� - Rx, RC6 - ����� - Tx,  
					; RC1 � RC2 - ������ ���
 
; ���� D 
    movlw		b'11110000'	; RD0-RD3 - ������, ���������� �����������
    movwf   	TRISD			; RD4-RD7 - ����� � �������� �����������

; ���� E 
    clrf		TRISE		; <0:2> - ������
    bsf			TRISE,3		; MCLR

    movlw		b'00000100'    ; �������������� Timer0.
    movwf		OPTION_REG     ; ���������� 1:32

;��� 
    movlw     	0x00			; Left Justified, Vdd-Vss referenced
    movwf     	ADCON1

; ���
    movlw	   	0x65		; ������� 0,6���
    movwf	   	PR2

; RS232
; ������� = 0, �������� ��� = 1
;	movlw		0x0C            ; �������� 19200 �������/� 
    movlw		0x19            ; �������� 9600 �������/� 
    movwf		SPBRG

    movlw		b'00100100'     ; brgh = high (2)
    movwf		TXSTA           ; ������� ����������� ��������, set brgh

;--------------  Bank 3 --------------
    bsf			STATUS,RP1	; select Register Bank 3

    movlw		b'00001111'	; RA0,RA1,RA,RA3 - ���������� ����� - ������ �����
    movwf		ANSEL

    clrf  		ANSELH          ; ��� ��������� ����� - �����

;--------------  Bank 0 --------------
    bcf			STATUS,RP0	; back to Register Bank 0
    bcf			STATUS,RP1

;==== �������������� ���
    clrf		CCP2CON		; �������� ��� ������ ���������
    clrf		CCP1CON		; �������� ��� ������� ���������
    clrf		TMR2		; ������� ������� 2
    clrf		CCPR2L		; ���������� = 0% ������ ���������
    clrf		CCPR1L		; ���������� = 0% ������� ��������� 

    movlw		b'00101100'	;
    movwf		CCP2CON		; ���������� ��� ������ ���������
    movwf		CCP1CON		; ���������� ��� ������� ��������� 
	   	  
;==== �������������� ������ ���
    bcf			PIR1,TMR2IF	; ������� ����� ���������� �������
	
    clrf		T2CON		  
    bsf			T2CON,T2CKPS1	; prescaler = 16
    bsf			T2CON,TMR2ON	; ���������� ������

;==== ������� ����� ��� � ������ RDx
    clrf		ADRESH
    bcf			PORTD,0
    bcf			PORTD,1
    bcf			PORTD,2
    bcf			PORTD,3

; === ������� ����� ���������
    clrf		RS232Received		; �������� ������� ������� ������
    clrf		CurrentSongNumber	; ������� ������� - ������ ���������������
    clrf		Barriers		; ������� ����� ��������� �������� �����������
    clrf		LineCount		; ������� ������� ���������������� �������
    clrf		CycleCounterL	
    clrf		CycleCounterH

;==== ���������� �������
    bcf			PORTE,0
    bcf			PORTE,1
    bcf			PORTE,2
    bcf			PORTA,4

;==== RS232
    movlw		b'10010000'		; ������� ����������� ����
    movwf		RCSTA

;==== ��������� �������� 
    clrf 		Delay
settle:
    decfsz 		Delay,F
    goto 		settle     	

    movf 		RCREG,W 		; ������� ����� �����
    movf 		RCREG,W
    movf 		RCREG,W    

;==== 
    bsf			PORTE,1   		; �������� �����
    call		Delay_1_sec
    call		Delay_1_sec
    bcf			PORTE,1

;====
    movlw		b'11111111'
    movwf		MessageStart
    movlw		'#'
    movwf		MessageEnd 

; *******************************************************************
; *		 �������� ������� ����
; *******************************************************************

    call		ShortBeep	; ������� ���������������� 
    call		WelcomeMessage	; � ������� ����������� �� RS232
    
    clrf		CurrentValue	; ��������� ���������� �� ��� ������ �����

    clrf		LineState	; 4 ������� ����(<0:3>) - ������ �����
					; <4> - �������/���������� ���������������� ����� - ��� ��������
					; <5> - ��������� - �� �� ��������� �����
					; <6> - ���� ���������, �� ���������� �� RS232 - ���� - ��������������
    bsf			LineState,7	; <7> - ������ �������� ���������� ������ ��� - ����������� ������������� ������� �����������

 	; ����� ������������ ������� �����
;	movlw		b'00010100'		; 0,4B
;	movlw		b'00011001'		; 0,5B
;	movlw		b'00011110'		; 0,6B
;	movlw		b'00100011'		; 0,7B
;	movlw		b'00101000'		; 0,8B
;	movlw		b'00101101'		; 0,9B
    movlw		b'00110010'		; 1,0B
;	movlw		b'00111101'		; 1,2B
;	movlw		b'01001100'		; 1,5B
;	movlw		b'01100110'		; 2�
    movwf		VoltageTreshhold; 

    clrf		SpaceOptions	; 

    bsf			LineState,6		; ���������� ��� ������ �� RS232
    bsf			LineState,5		; ����� �� ��������� �����

    call      	L_STOP_R_STOP 	; ���������

MainLoop:
 
LineDetectorCheck:
;========= ������� ������ ������ ==========

	; �������� �������� ������� �������� ������� �����
    movlw		b'10000001'		; RA0 (AN0)
    movwf		ADCON0 			; configure A2D for Fosc/8, and turn on the A2D module

    call		StartADC		; ������ ��������������

CheckADC_LR:

    btfsc		ADCON0,GO_DONE		; ��� ��������� ����� ���������� ��������������
    goto		CheckPWM_LR

    movf		LineRight,w		; ��� �������� � ������������ �������
    movwf		CurrentValue

    movf		ADRESH,w		; ��������� �������� � ���

    movwf		LineRightDebug

    btfss		LineState,7	
    goto		IsNotFirstPass_LR	; 7� = 0 
						; ������ ������ ��� ����������� ����������� 
    movwf		LineRight		; ������� �������� ����������� �������� ������� �������� ������� �����  
    goto		Sensor_LMR		; �������� ���������� �������

IsNotFirstPass_LR:	

    call 		SurfaseCheck		; �������� ��������� ��������� � ��� ��������

    btfsc		CurrentValue,0		; ������� �� ������������ ������ � �����
    goto		GotLine_LR
    bcf			LineState,0		; ������ ��� ����������� �����
    goto		Sensor_LMR		; �������� ���������� �������

GotLine_LR:

    bsf			LineState,0		; �������� ��� ����������� �����
    goto		Sensor_LMR		; �������� ���������� �������


; �������� ��� ��������� �������� �������� ���������� �� �������
CheckPWM_LR:
    call 		CheckPWMTimer		; ���������� ������� ��� ������������ ������� ���
    call 		ReceiveBit 		; �������� ����������� ����� ������
    call		MasterToldMe		; ���������� �������� �������

    goto		CheckADC_LR		 
	

;========= ������� ������ ������ ==========

Sensor_LMR: ; �������� �������� ������� �������� ������� �����

    movlw		b'10000101'		; RA1 (AN1)
    movwf		ADCON0 		

    call		StartADC		; ������ ��������������

CheckADC_LMR:

    btfsc		ADCON0,GO_DONE		; ��� ��������� ����� ���������� ��������������
    goto		CheckPWM_LMR

    movf		LineMiddleRight,w	; ��� �������� � ������������ �������
    movwf		CurrentValue

    movf		ADRESH,w		; ��������� �������� � ���	

    movwf		LineMiddleRightDebug

    btfss		LineState,7	
    goto		IsNotFirstPass_LMR	; 7� = 0 
						; ������ ������ ��� ����������� ����������� 
    movwf		LineMiddleRight		; ������� �������� ����������� �������� ������� �������� ������� �����  
    goto		Sensor_LML		; �������� ���������� �������

IsNotFirstPass_LMR:	

    call 		SurfaseCheck		; �������� ��������� ��������� � ��� ��������

    btfsc		CurrentValue,0		; ������� �� ������������ ������ � �����
    goto		GotLine_LMR
    bcf			LineState,1		; ������ ��� ����������� �����
    goto		Sensor_LML		; �������� ���������� �������

GotLine_LMR:

    bsf			LineState,1		; �������� ��� ����������� �����
    goto		Sensor_LML		; �������� ���������� �������

	
CheckPWM_LMR:
    call 		CheckPWMTimer		; ���������� ������� ��� ������������ ������� ���
    call 		ReceiveBit 		; �������� ����������� ����� ������
    call		MasterToldMe		; ���������� �������� �������

    goto		CheckADC_LMR		  

;========= ������� ����� ������ ==========

Sensor_LML:	; �������� �������� ������ �������� ������� �����  

    movlw		b'10001001'		; RA2 (AN2)
    movwf		ADCON0 			; configure A2D for Fosc/8, and turn on the A2D module

    call		StartADC		; ������ ��������������

CheckADC_LML:

    btfsc		ADCON0,GO_DONE		; ��� ��������� ����� ���������� ��������������
    goto		CheckPWM_LML

    movf		LineMiddleLeft,w	; ��� �������� � ������������ �������
    movwf		CurrentValue

    movf		ADRESH,w		; ��������� �������� � ��� 

    movwf		LineMiddleLeftDebug

    btfss		LineState,7	
    goto		IsNotFirstPass_LML	; 7� = 0 
						; ������ ������ ��� ����������� ����������� 
    movwf		LineMiddleLeft		; ������� �������� ����������� �������� ������� �������� ������� �����  
    goto		Sensor_LL		; �������� ���������� �������

IsNotFirstPass_LML:	

    call 		SurfaseCheck		; �������� ��������� ��������� � ��� ��������

    btfsc		CurrentValue,0		; ������� �� ������������ ������ � �����
    goto		GotLine_LML
    bcf			LineState,2		; ������ ��� ����������� �����
    goto		Sensor_LL		; �������� ���������� �������

GotLine_LML:

    bsf			LineState,2		; �������� ��� ����������� �����

    goto		Sensor_LL		; �������� ���������� �������

CheckPWM_LML:
    call 		CheckPWMTimer		; ���������� ������� ��� ������������ ������� ���
    call 		ReceiveBit 		; �������� ����������� ����� ������
    call		MasterToldMe		; ���������� �������� �������

    goto		CheckADC_LML

;========= ������� ����� ������ ==========

Sensor_LL:	; ����. �������� �������� ������ �������� ������� �����  

    movlw		b'10001101'		; RA3 (AN3)
    movwf		ADCON0 			; configure A2D for Fosc/8, and turn on the A2D module
    call		StartADC		; ������ ��������������

CheckADC_LL:

    btfsc		ADCON0,GO_DONE		; ��� ��������� ����� ���������� ��������������
    goto		CheckPWM_LL

    movf		LineLeft,w		; ��� �������� � ������������ �������
    movwf		CurrentValue

    movf		ADRESH,w		; ��������� �������� � ���

    movwf		LineLeftDebug

    btfss		LineState,7	
    goto		IsNotFirstPass_LL	; 7� = 0 
						; ������ ������ ��� ����������� ����������� 
    movwf		LineLeft		; ������� �������� ����������� �������� ������� �������� ������� �����  
    goto		EndLineDetectorCheck	; �������� ���������� �������

IsNotFirstPass_LL:	

    call 		SurfaseCheck		; �������� ��������� ��������� � ��� ��������

    btfsc		CurrentValue,0		; ������� �� ������������ ������ � �����
    goto		GotLine_LL
    bcf			LineState,3		; ������ ��� ����������� �����
    goto		EndLineDetectorCheck	; �������� ���������� �������

GotLine_LL:

    bsf			LineState,3		; �������� ��� ����������� �����
    goto		EndLineDetectorCheck	; �������� ���������� �������

CheckPWM_LL:
    call 		CheckPWMTimer	; ���������� ������� ��� ������������ ������� ���
    call 		ReceiveBit      ; �������� ����������� ����� ������
    call		MasterToldMe	; ���������� �������� �������

    goto		CheckADC_LL		

EndLineDetectorCheck:
;========= ��������� ����� ������� ����� ==========

;========= �� ������� ����������� ==========

    movlw		b'11110000'		; ������� ������ � ������� ����������� 
    andwf		PORTD,w
    movwf		Barriers

;========= ���������� ������� ����������� ==========

;CheckRightContact:
    movlw		5			; ����� ������
    movwf		StableStateCounter
    clrf		ButtonPushCounter	

Debounce0:				    ; ������
    clrw				    ; assume it's not, so clear
    btfss		PORTB,0             ; wait for switch to go low
    incf		ButtonPushCounter,w ; if it's low, bump the counter
    movwf		ButtonPushCounter   ; store either the 0 or incremented value

    decfsz		StableStateCounter,f	; ������� �����
    goto		Debounce0

    movf		ButtonPushCounter,w ; have we seen 5 in a row?
    xorlw		5
    btfss		STATUS,Z     
    goto		RightNotPushed

	; �� ���-�� ���������
    bcf			LineState,6			; ����������� ���������� ������������� �� ����� � RS232
    bcf			Barriers,3			;

    goto		CheckLeftContact

RightNotPushed:
    bsf			Barriers,3			;

CheckLeftContact:					; ����� ������

    movlw		5
    movwf		StableStateCounter
    clrf		ButtonPushCounter	

Debounce1:
    clrw                            ; assume it's not, so clear
    btfss		PORTB,1             ; wait for switch to go low
    incf		ButtonPushCounter,w ; if it's low, bump the counter
    movwf		ButtonPushCounter   ; store either the 0 or incremented value

    decfsz		StableStateCounter,f; ������� �����
    goto		Debounce1

    movf		ButtonPushCounter,w ; have we seen 5 in a row?
    xorlw		5
    btfss		STATUS,Z     
    goto		LeftNotPushed

	; �� ���-�� ���������
    bcf			LineState,6			; ����������� ���������� ������������� �� ����� � RS232
    bcf			Barriers,2			;

    goto		EndSensorCheck
	
LeftNotPushed:
    bsf			Barriers,2			; 

EndSensorCheck:
;========= ��������� ����� ������� ����������� ==========

    bcf			LineState,7				; ������ ����� �������� - ������������ ����������� ����������

    btfsc		LineState,6				; ����������� ���������� ������������� �� ����� � RS232
    goto		MovementCorrection

    btfss		LineState,5				; ���� ����� �� ��������� �����, ���� � �� ������!
    goto		MovementCorrection

    bcf			LineState,5				; ����� � �����

    btfss		Barriers,2
    bsf			SpaceOptions,5				; ������ ����� "��" -  ������ ����� �����

    btfss		Barriers,3
    bsf			SpaceOptions,7				; ������ ������ "��" -  ������ ����� ������

    bsf			Barriers,2				; ����� ���������� � ����� - ��������� ���� �� ����� 
    bsf			Barriers,3				; ������ ���������� � ����� - �������� ���� �� �����
    bsf			SpaceOptions,1			; ��������� ���� ��������� �������� �� �������

    call		L_FORWARD_R_FORWARD 	; ����� � �����

    call		Delay_197_ms			; ����� ����� ������
    call		Delay_197_ms			; ����� ����� ������
    call		Delay_197_ms			; ����� ����� ������

MovementCorrection:

	; ������� ��������, �� ��������� �� �����������
    btfsc		Barriers,2				; ���� ��������� - �� �����, ������ �� ������
    goto		CheckOnceMore

    call		EmergencyCorrection		

    goto		MainLoop 				; ���������� ����������, ���������� �������� ������

CheckOnceMore:
    btfsc		Barriers,3				; ���� ��������� - �� �����, ������ �� ������
    goto		EverythingIsOk

    call		EmergencyCorrection		

    goto		MainLoop 				; ���������� ����������, ���������� �������� ������


EverythingIsOk:

	; ���� �� ������, ���������� ������ ������� �����
    movlw		b'00001111'				; ������� ������ � ������� ����� 
    andwf		LineState,w
	
    movwf		CurrentValue			; ���� �� ���� ����������� �� ��������� �����
    movf		CurrentValue,f			; ���� ����� ����� 0, �� ����� ��������� ��� Z �������� STATUS

    btfss		STATUS,Z				; �������� ��� ����
    goto		LineFound
    goto		NoLineFound
	
LineFound:
    call		TrackTheLine	     	; �������������� ��������� �� ���� ������� �����

    goto		MainLoop 

NoLineFound:
    call		CrawlingAlongTheWall	; �������������� ��������� �� ���� �������� �����������

    goto		MainLoop 


;========================������������================================
; *******************************************************************
; *		����� �������� ����� ����� - ����� �������� 
; *		�� ����� ���������
; *******************************************************************
CrawlingAlongTheWall:

    movfw		Barriers				; ����� ��������� �������� �����������
										; <7:2> - ��������� ��������
										; Barriers,3			;
										; <7> - ������ ��
										; <6> - ������ ��
										; <5> - ������� ��
										; <4> - ����� ��
										; <3> - ������ ����������
										; <2> - ����� ����������
	
    movwf		CurrentValue			; �������� �� ������� 

	; SpaceOptions						; ��������� ��������� ������ - �����������, ����� � ��
										; <7> - ������ ���� ������
										; <6> - ������ ���� ������� - �������, ����� 
										; <5> - ������ ���� �����
										; <4> - 
										; <3> - 
										; <2> - 
										; <1> - ���� ��������� �������� �� �������
										; <0> - ���� �����

    bcf			LineState,4				; ���� �� � ���� �����, �� ������ ����� ��� ������� ��� 
										; ������ ��� ������� ���������������� �����

    btfsc		LineState,6		     	; ����������� ���������� ������������� �� ����� � RS232
    goto		EndCrawlingAlongTheWall ;

Crawling0:
    movf      	CurrentValue,w  
    xorlw     	b'11111100'				; ��� �����������
    btfss     	STATUS,Z     
    goto      	Crawling1
    call      	L_FORWARD_R_FORWARD   	; �������� �����

	; ��� ��������� �������, ����� ����
    btfss		SpaceOptions,1			; ���� ����� ���� ��������� �������� �� �������, 
    goto      	EndCrawlingAlongTheWall ; �� ����� �� ��������� �����


	; ��������� ������� ����� ��������������� ������� � ��� �� ������������
    call		CheckTimer0				; �������� ����������� � ���������

    movf      	CycleCounterL,w   
    xorlw     	b'01111111'				; ���������������� ��������� �����
    btfss     	STATUS,Z     
    goto      	EndCrawlingAlongTheWall 

	; ���� ���������� ����� ����� ������������ � ����� ������ ������
	; ��� �� ����� ����������� �������� � ����������� �� �������� ������������ ������

	; ������������ ��� ������ �� ���� ���� �� ������

    btfsc		SpaceOptions,7			; ������ ���� ������
    call      	L_FORWARD_R_STOP 		; ������� ����� ������

    btfsc		SpaceOptions,5			; ������ ���� �����
    call      	L_STOP_R_FORWARD 		; ������� ����� �����

    call		Delay_197_ms			; ����� ����� ���������
    call		Delay_197_ms			; ����� ����� ���������
    call		Delay_197_ms			; ����� ����� ���������

    goto      	EndCrawlingAlongTheWall 

Crawling1:
    movf      	CurrentValue,w  
    xorlw     	b'11101100'				; ������ ����� 
    btfss     	STATUS,Z     
    goto      	Crawling2

    bcf			SpaceOptions,7			; �������� ������ ������

    bsf			SpaceOptions,5			; ����� ������ �����
    bsf			SpaceOptions,1			; ��������� ���� ��������� �������� �� �������

    call      	L_FORWARD_R_STOP 		; ������� ����� ������
    goto      	EndCrawlingAlongTheWall	

Crawling2:
    movf      	CurrentValue,w  
    xorlw     	b'11001100'				; ������ �����  � ����������� �������
    btfss     	STATUS,Z     
    goto      	Crawling3

    bsf			SpaceOptions,6			; ����� ������ �������	
    bsf			SpaceOptions,1			; ��������� ���� ��������� �������� �� �������

    call      	L_BACKWARD_R_BACKWARD  	; ������ ������� �����, ����� ���������� �� ����������� �� ���������

    call		Delay_197_ms			; ����� ����� ��������
    call		Delay_197_ms			; ����� ����� ��������
    call		Delay_197_ms			; ����� ����� ��������

	; ���� ���������, �� ����������� �� �� � ���� - �� ������ ������

    btfss		SpaceOptions,7			; ���� ���� ������ ������ - ������� ��� � ����
    goto      	Crawling2Normal	
    call      	L_BACKWARD_R_FORWARD  	; �������� �� ����� ������ ������� �������

    call		Delay_197_ms			; ����� ����� ��������
    call		Delay_197_ms			; ����� ����� ��������
    call		Delay_197_ms			; ����� ����� ��������

    goto      	EndCrawlingAlongTheWall	

Crawling2Normal: 						; �� ���� ������ ������ 

    call      	L_FORWARD_R_BACKWARD  	; �������� �� ����� �� ������� �������

    call		Delay_197_ms			; ����� ����� ��������
    call		Delay_197_ms			; ����� ����� ��������
    call		Delay_197_ms			; ����� ����� ��������

    bcf			SpaceOptions,7			; �������� ������ ������
    bsf			SpaceOptions,5			; ����� ������ �����

    goto      	EndCrawlingAlongTheWall	

Crawling3:
    movf      	CurrentValue,w  
    xorlw     	b'10011100'				; ������ ������  � ����������� �������
    btfss     	STATUS,Z     
    goto      	Crawling4

    bsf			SpaceOptions,6			; ����� ������ �������	
    bsf			SpaceOptions,1			; ��������� ���� ��������� �������� �� �������

    call      	L_BACKWARD_R_BACKWARD  	; ������ ������� �����, ����� ���������� �� ����������� �� ���������

    call		Delay_197_ms			; ����� ����� ��������
    call		Delay_197_ms			; ����� ����� ��������
    call		Delay_197_ms			; ����� ����� ��������

    btfss		SpaceOptions,5			; ���� ���� ������ ����� - ������� ��� � ����
    goto      	Crawling3Normal	
    call      	L_FORWARD_R_BACKWARD  	; �������� �� ����� �� ������� �������

    call		Delay_197_ms			; ����� ����� ��������
    call		Delay_197_ms			; ����� ����� ��������
    call		Delay_197_ms			; ����� ����� ��������

    goto      	EndCrawlingAlongTheWall	

Crawling3Normal: 						; �� ���� ������ �����

    call      	L_BACKWARD_R_FORWARD  	; �������� �� ����� ������ ������� �������

    call 		Delay_197_ms			; ����� ����� ������������
    call 		Delay_197_ms			; ����� ����� ������������
    call		Delay_197_ms			; ����� ����� ��������

    bcf			SpaceOptions,5			; �������� ������ �����
    bsf			SpaceOptions,7			; ����� ������ ������

    goto      	EndCrawlingAlongTheWall	

Crawling4:

    movf      	CurrentValue,w  
    xorlw     	b'10111100'				; ������ ������
    btfss     	STATUS,Z     
    goto      	Crawling5

    bcf			SpaceOptions,5			; �������� ������ �����

    bsf			SpaceOptions,7			; ����� ������ ������
    bsf			SpaceOptions,1			; ��������� ���� ��������� �������� �� �������

    call      	L_STOP_R_FORWARD 		; ������� ����� �����

    goto      	EndCrawlingAlongTheWall

Crawling5:
    movf      	CurrentValue,w  
    xorlw     	b'11011100'				; ������ ����� �� �����
    btfss     	STATUS,Z     
    goto      	CrawlingBack

    bsf			SpaceOptions,6			; ����� ������ �������	

	; ����� ����������� �������� � ����������� �� ���� ������������ ������!

    call      	L_BACKWARD_R_BACKWARD  	; ������ ������� �����, ����� ���������� �� ����������� �� ���������

    call		Delay_197_ms			; ����� ����� ��������
    call		Delay_197_ms			; ����� ����� ��������
    call		Delay_197_ms			; ����� ����� ��������

    btfss		SpaceOptions,5			; ���� ������ ����� - ���� ������������ 
    call      	L_FORWARD_R_BACKWARD  	; �������� �� ����� �� ������� �������

    btfsc		SpaceOptions,7			; ���� ������ ������ - ���� ������������ 
    call      	L_BACKWARD_R_FORWARD  	; �������� �� ����� ������ ������� �������

    call		Delay_197_ms			; ����� ����� ������������
    call		Delay_197_ms			; ����� ����� ������������
    call		Delay_197_ms			; ����� ����� ������������

    bcf			SpaceOptions,5			; �������� ������ �����
    bcf			SpaceOptions,7			; �������� ������ ������

    goto      	EndCrawlingAlongTheWall


CrawlingBack:

;	movf      	CurrentValue,w  
;    xorlw     	b'01110000'				; 
;    btfss     	STATUS,Z     
    btfsc     	CurrentValue,7     
    goto      	EndCrawlingAlongTheWall
    
;	call		L_STOP_R_STOP
	
    goto      	EndCrawlingAlongTheWall

EndCrawlingAlongTheWall:				; 

    return


; *******************************************************************
; *		��������� ������� ���������� ��������
; *******************************************************************

EmergencyCorrection:

    movf		Barriers,w				; ����� ��������� �������� �����������
    movwf		CurrentValue			; �������� �� ������� 

    movlw		b'00001100'				; ������� ������ � ������������
    andwf		CurrentValue,f

    movf		CurrentValue,f			; ���� �� �� 0 �� Z = 1	
;	movf      	CurrentValue,w  
;   xorlw     	b'00000000'				; ������ ����� �� ����� - �����������
    btfss     	STATUS,Z     
    goto      	Correction1

    bsf			SpaceOptions,6			; ����� ������ �������	

	; ����� ����������� �������� � ����������� �� ���� ������������ ������!

    call      	L_BACKWARD_R_BACKWARD  	; ������ ������� �����, ����� ���������� �� ����������� �� ���������

    call		Delay_197_ms			; ����� ����� ��������
    call		Delay_197_ms			; ����� ����� ��������
    call		Delay_197_ms			; ����� ����� ��������

    btfss		SpaceOptions,5			; ���� ������ ����� - ���� ������������ 
    call      	L_FORWARD_R_BACKWARD  	; �������� �� ����� �� ������� �������

    btfsc		SpaceOptions,7			; ���� ������ ����� - ���� ������������ 
    call      	L_BACKWARD_R_FORWARD  	; �������� �� ����� ������ ������� �������

    call		Delay_197_ms			; ����� ����� ������������
    call		Delay_197_ms			; ����� ����� ������������
    call		Delay_197_ms			; ����� ����� ������������
    call		Delay_197_ms			; ����� ����� ������������

    goto      	EndEmergencyCorrection

Correction1:
    movf      	CurrentValue,w  
    xorlw     	b'00001000'				; ������ ����� �� ����� - �����������
    btfss     	STATUS,Z     
    goto      	Correction2

    bcf			SpaceOptions,7			; �������� ������ ������

    bsf			SpaceOptions,5			; ����� ������ �����
    bsf			SpaceOptions,1			; ��������� ���� ��������� �������� �� �������

    call      	L_BACKWARD_R_BACKWARD  	; ������ ������� �����, ����� ���������� �� ����������� �� ���������

    call		Delay_197_ms			; ����� ����� ��������
    call		Delay_197_ms			; ����� ����� ��������
    call		Delay_197_ms			; ����� ����� ��������
    call		Delay_197_ms			; ����� ����� ��������

    call      	L_FORWARD_R_BACKWARD  	; �������� �� ����� �� ������� �������

    call		Delay_197_ms			; ����� ����� ��������
    call		Delay_197_ms			; ����� ����� ��������

    goto      	EndEmergencyCorrection

Correction2:
    movf      	CurrentValue,w  
    xorlw     	b'00000100'				; ������ ������ �� ����� - �����������
    btfss     	STATUS,Z     
    goto      	EndEmergencyCorrection

    bcf			SpaceOptions,5			; �������� ������ �����

    bsf			SpaceOptions,7			; ����� ������ ������
    bsf			SpaceOptions,1			; ��������� ���� ��������� �������� �� �������

    call      	L_BACKWARD_R_BACKWARD  	; ������ ������� �����, ����� ���������� �� ����������� �� ���������

    call		Delay_197_ms			; ����� ����� ��������
    call		Delay_197_ms			; ����� ����� ��������
    call		Delay_197_ms			; ����� ����� ��������
    call		Delay_197_ms			; ����� ����� ��������

    call      	L_BACKWARD_R_FORWARD  	; �������� �� ����� ������ ������� �������

    call		Delay_197_ms			; ����� ����� ��������
    call		Delay_197_ms			; ����� ����� ��������

EndEmergencyCorrection:

    return

; *******************************************************************
; *		������������� �������� ������������ ����� � �����
; *******************************************************************
TrackTheLine:

    movlw		b'00001111'		; ������� ������ � ������� ����� - ���� �� ��� ����� ��������� � ������� ����� �����
    andwf		LineState,w
	
    movwf		CurrentValue	; �������� �� �������

CheckOnceAgain:

;GoForward - ���������� ���� �����
    movf      	CurrentValue,w    
    xorlw     	b'00000000'
    btfss     	STATUS,Z     
    goto      	GoForward

    btfss		LineState,6		     	; ����������� ���������� ������������� �� ����� � RS232
    call      	L_FORWARD_R_FORWARD   	; �������� �����

    btfss		LineState,4				; ���� ��� ������� ����� ���������
    goto      	CorrectionMade

    bcf			LineState,4				; �� ����� ����������� ������ ���

    clrf		CycleCounterL			; ������� ������� �������
    clrf		CycleCounterH			; 

    goto      	CorrectionMade
   
GoForward:

    movf      	CurrentValue,w  
    xorlw     	b'00000110'
    btfss     	STATUS,Z     
    goto      	GoToTheRight

    btfss		LineState,6		     	; ����������� ���������� ������������� �� ����� � RS232
    call      	L_FORWARD_R_FORWARD   	; �������� �����

    btfss		LineState,4				; ���� ��� ������� ����� ���������
    goto      	CorrectionMade

    bcf			LineState,4				; �� ����� ����������� ������ ���

    clrf		CycleCounterL			; ������� ������� �������
    clrf		CycleCounterH			; 

    goto      	CorrectionMade

GoToTheRight:

    movf      	CurrentValue,w  
    xorlw     	b'00000100'
    btfss     	STATUS,Z     
    goto      	GoToTheRight2

    btfss		LineState,6		     	; ����������� ���������� ������������� �� ����� � RS232
    call      	L_STOP_R_FORWARD 		; ������� ����� �����

    btfss		LineState,4				; 
    goto      	CorrectionMade

    bcf			LineState,4				; �� ����� ����������� ������ ���

    clrf		CycleCounterL			; ������� ������� �������
    clrf		CycleCounterH			; 

    goto      	CorrectionMade

GoToTheRight2:

    movf      	CurrentValue,w  
    xorlw     	b'00001100'
    btfss     	STATUS,Z     
    goto      	GoToTheRightFast

    btfss		LineState,6		     	; ����������� ���������� ������������� �� ����� � RS232
    call      	L_BACKWARD_R_FORWARD  	; �������� �� ����� ������ ������� �������

;	btfss		LineState,4				; ���� ��� ������� ����� ���������
;	goto      	CorrectionMade

;	bcf			LineState,4				; �� ����� ����������� ������ ���

;	clrf		CycleCounterL			; ������� ������� �������
;	clrf		CycleCounterH			; 

    goto      	CorrectionMade

GoToTheRightFast:

    movf      	CurrentValue,w  
    xorlw     	b'00001000'
    btfss     	STATUS,Z     
    goto      	GoToTheLeft

    btfss		LineState,6		     	; ����������� ���������� ������������� �� ����� � RS232
    call      	L_BACKWARD_R_FORWARD  	; �������� �� ����� ������ ������� �������

    btfss		LineState,4				; ���� ��� ������� ����� ���������
    goto      	CorrectionMade

    bcf			LineState,4				; �� ����� ����������� ������ ���

    clrf		CycleCounterL			; ������� ������� �������
    clrf		CycleCounterH			; 

    goto      	CorrectionMade

GoToTheLeft:

    movf      	CurrentValue,w  
    xorlw     	b'00000010'
    btfss     	STATUS,Z     
    goto      	GoToTheLeft2

    btfss		LineState,6		     	; ����������� ���������� ������������� �� ����� � RS232
    call      	L_FORWARD_R_STOP 		; ������� ����� ������


    btfss		LineState,4				; ���� ��� ������� ����� ���������
    goto      	CorrectionMade

    bcf			LineState,4				; �� ����� ����������� ������ ���

    clrf		CycleCounterL			; ������� ������� �������
    clrf		CycleCounterH			; 

    goto      	CorrectionMade

GoToTheLeft2:

    movf      	CurrentValue,w  
    xorlw     	b'00000011'
    btfss     	STATUS,Z     
    goto      	GoToTheLeftFast

    btfss		LineState,6		     	; ����������� ���������� ������������� �� ����� � RS232
    call      	L_FORWARD_R_BACKWARD  	; �������� �� ����� �� ������� �������


;	btfss		LineState,4				; ���� ��� ������� ����� ���������
;	goto      	CorrectionMade

;	bcf			LineState,4				; �� ����� ����������� ������ ���

;	clrf		CycleCounterL			; ������� ������� �������
;	clrf		CycleCounterH			; 

    goto      	CorrectionMade

GoToTheLeftFast:

    movf      	CurrentValue,w  
    xorlw     	b'00000001'
    btfss     	STATUS,Z     
    goto      	PerpendicularLine1

    btfss		LineState,6		     	; ����������� ���������� ������������� �� ����� � RS232
    call      	L_FORWARD_R_BACKWARD  	; �������� �� ����� �� ������� �������

    btfss		LineState,4				; ���� ��� ������� ����� ���������
    goto      	CorrectionMade

    bcf			LineState,4				; �� ����� ����������� ������ ���

    clrf		CycleCounterL			; ������� ������� �������
    clrf		CycleCounterH			; 

    goto      	CorrectionMade

PerpendicularLine1:						; ���������� ���������������� �����

    movf      	CurrentValue,w  
    xorlw     	b'00001111'
    btfss     	STATUS,Z     
    goto      	PerpendicularLine2

    btfss		LineState,5				; �� ���� ������� ����� ���������� �� ������
    call		CountLines				; ��������� ��������� �����

    goto      	CorrectionMade

PerpendicularLine2:						; ���������� ���������������� �����

    movf      	CurrentValue,w  
    xorlw     	b'00000111'
    btfss     	STATUS,Z     
    goto      	PerpendicularLine3

    btfss		LineState,5				; �� ���� ������� ����� ���������� �� ������
    call		CountLines

    goto      	CorrectionMade

PerpendicularLine3:						; ���������� ���������������� �����

    movf      	CurrentValue,w  
    xorlw     	b'00001110'
    btfss     	STATUS,Z     
    goto      	CheckError1

    btfss		LineState,5				; �� ���� ������� ����� ���������� �� ������
    call		CountLines

    goto      	CorrectionMade

CheckError1:

    movf      	CurrentValue,w  
    xorlw     	b'00001101'				; ����� ��� ���� ������
    btfss     	STATUS,Z     
    goto      	CheckError2
    bsf			CurrentValue,1			; ������� � ���� 00001111
    goto      	CheckOnceAgain

CheckError2:

    movf      	CurrentValue,w  
    xorlw     	b'00001011'				; ����� ��� ���� ������
    btfss     	STATUS,Z     
    goto      	CorrectionMade
    bsf			CurrentValue,2			; ������� � ���� 00001111
    goto      	CheckOnceAgain

CorrectionMade:

    return

; *******************************************************************
; *		������� ����� �������� - ����������� ������ ���������
; *******************************************************************
CountLines:
	; ����� �������� � ����� ������ � �������������� ��������� ������� 

    btfsc		LineState,4				; ���� ��� ������� ����� ���������, ���������
    goto		IncrementCounters		
	
    clrf		CycleCounterL			; ������� ��������
    clrf		CycleCounterH

IncrementCounters: 

    bsf			LineState,4				; �������� ��� ������� �����

    btfsc		LineState,6				; ������ ���������� - �� ���� ��������������
    goto      	EndCountLines

    call		CheckTimer0				; �������� ����������� � ���������

    movf      	CycleCounterL,w   
    xorlw     	b'00010100'				; 20 ������������ �������
    btfss     	STATUS,Z     
    goto      	EndCountLines 

    call		PlaySong				; ��������������� ������� - ���� ������ ���������

EndCountLines:

    return

; *******************************************************************
; *		�������� ������������ � ���������
; *******************************************************************
CheckTimer0:

    btfss		INTCON,T0IF   			; ���� ������������ Timer0 
    goto		EndCheckTimer0
    bcf			INTCON,T0IF    			; ����������� ����� ����� ������������
    incf		CycleCounterL,f 		; �������� ����� ������ ������� �� 1
    btfsc		STATUS,Z   				; �������� ������� ����� ���� ������� ������������� �� 128
    incf		CycleCounterH,f 		; �������� ����� ������ ������� �� 1

EndCheckTimer0:
    return


; *******************************************************************
; *		��������������� ������� �� � ������ - ��������� �������� ��� ������ �������
; *		+ ������������ ������� ������ ������
; *******************************************************************
PlaySong:

;	btfss		LineState,6				; ����������� ���������� ������������� �� ����� � RS232
;    call      	L_FORWARD_R_FORWARD   	; �������� �����

;	call		Delay_1_sec				; ������ � ����� �������
 
    call      	L_STOP_R_STOP 			; ���������

    call		TurnScreenOn			; ������� ������� �����
    call		PlayPauseCurrentSong	; ��������������� ��������� �������

	;=====	��������� ���������
    bsf       	STATUS,RP0				; ����� Register Bank 1
    movlw		b'00000111'     		; �������������� Timer0.
    movwf		OPTION_REG      		; ���������� 1:256
    bcf       	STATUS,RP0				; ����� Register Bank 1

    clrf		CycleCounterL			; ������� ������� �������
    clrf		CycleCounterH			; 

Room1Delay:

    movf      	CurrentSongNumber,w    
    xorlw     	b'00000000'
    btfss     	STATUS,Z     
    goto      	Room2Delay
 
    call		CheckTimer0

    movf      	CycleCounterH,w   
    xorlw     	b'00000001'				; 18 ������
    btfss     	STATUS,Z     
    goto		$-4						; ������� �� �������� �������    
    goto      	SetNextRoomNumber 

Room2Delay:
    movf      	CurrentSongNumber,w    
    xorlw     	b'00000001'
    btfss     	STATUS,Z     
    goto      	Room3Delay

    call		CheckTimer0

    movf      	CycleCounterH,w   
    xorlw     	b'00000001'				; 18 ������
    btfss     	STATUS,Z     
    goto		$-4						; ������� �� �������� �������    
    goto      	SetNextRoomNumber 

Room3Delay:
    movf      	CurrentSongNumber,w    
    xorlw     	b'00000010'
    btfss     	STATUS,Z     
    goto      	Room4Delay

    call		CheckTimer0

    movf      	CycleCounterH,w   
    xorlw     	b'00000001'				; 18 ������
    btfss     	STATUS,Z     
    goto		$-4						; ������� �� �������� �������    

	
    call		L_STOP_R_STOP			; ����������� � ����� ������

    bsf			LineState,6				; ����������� ���������� ������������� �� ����� � RS232

    goto      	SetNextRoomNumber 

Room4Delay:
    movf      	CurrentSongNumber,w    
    xorlw     	b'00000011'
    btfss     	STATUS,Z     
    goto      	Room5Delay

    call		CheckTimer0

    movf      	CycleCounterH,w   
    xorlw     	b'00000001'				; 18 ������
    btfss     	STATUS,Z     
    goto		$-4						; ������� �� �������� �������   
    goto      	SetNextRoomNumber 

Room5Delay:
    movf      	CurrentSongNumber,w    
    xorlw     	b'00000100'
    btfss     	STATUS,Z     
    goto      	Room6Delay

    call		CheckTimer0

    movf      	CycleCounterH,w   
    xorlw     	b'00000001'				; 18 ������
    btfss     	STATUS,Z     
    goto		$-4						; ������� �� �������� �������    
    goto      	SetNextRoomNumber 

Room6Delay:
    movf      	CurrentSongNumber,w    
    xorlw     	b'00000101'
    btfss     	STATUS,Z     
    goto      	Room7Delay

    call		CheckTimer0

    movf      	CycleCounterH,w   
    xorlw     	b'00000001'				; 18 ������
    btfss     	STATUS,Z     
    goto		$-4						; ������� �� �������� �������    
    goto      	SetNextRoomNumber 

Room7Delay:
    movf      	CurrentSongNumber,w    
    xorlw     	b'00000110'
    btfss     	STATUS,Z     
    goto      	Room8Delay

    call		CheckTimer0

    movf      	CycleCounterH,w   
    xorlw     	b'00000001'				; 18 ������
    btfss     	STATUS,Z     
    goto		$-4						; ������� �� �������� �������    
    goto      	SetNextRoomNumber 

Room8Delay:
    movf      	CurrentSongNumber,w    
    xorlw     	b'00000111'
    btfss     	STATUS,Z     
    goto      	Room9Delay

    call		CheckTimer0

    movf      	CycleCounterH,w   
    xorlw     	b'00000001'				; 18 ������
    btfss     	STATUS,Z     
    goto		$-4						; ������� �� �������� �������    
    goto      	SetNextRoomNumber 

Room9Delay:
    movf      	CurrentSongNumber,w    
    xorlw     	b'00001000'
    btfss     	STATUS,Z     
    goto      	SetNextRoomNumber

    call		CheckTimer0

    movf      	CycleCounterH,w   
    xorlw     	b'00000001'				; 18 ������
    btfss     	STATUS,Z     
    goto		$-4						; ������� �� �������� �������    
	
    call		L_STOP_R_STOP			; ����������� � ����� ������

    bsf			LineState,6				; ����������� ���������� ������������� �� ����� � RS232
	
    goto      	SetNextRoomNumber 

SetNextRoomNumber:

    call		TurnScreenOn			; ������� ������� �����
    call		PlayPauseCurrentSong	; �����
    call		NextSong				; ������� �� ���� �������

    incf		CurrentSongNumber		; ��������� �������

	; ����� ��������� ������� ��� "���������" �� ���� � ����������� �����
    bsf       	STATUS,RP0				; ����� Register Bank 1
    movlw		b'00000100'     		; �������������� Timer0.
    movwf		OPTION_REG      		; ���������� 1:32
    bcf       	STATUS,RP0				; ����� Register Bank 1

    clrf		CycleCounterL			; ������� ������� �������
    clrf		CycleCounterH			; 

    bcf			LineState,4				; ������ ��� ������� �����

    btfss		LineState,6				; ����������� ���������� ������������� �� ����� � RS232
    call      	L_FORWARD_R_FORWARD   	; �������� �����

    call		Delay_6_sec				; ������� ������� ����� ����� - ����� ��� ���������� �� � ����

    return

;============= ���������� ������� ==============
;	bsf			PORTE,0   			; � 
;	bcf			PORTE,0
;	bsf			PORTE,1   			; Play/Pause
;	bcf			PORTE,1
;	bsf			PORTE,2   			; Next
;	bcf			PORTE,2
;	bsf			PORTA,4   			; Prev
;	bcf			PORTA,4

PlayPauseCurrentSong:					; ������������� �������
    call		Delay_197_ms		; ��������� ��������
    call		Delay_197_ms
    call		Delay_197_ms
    call		Delay_197_ms

    bsf			PORTE,1   			; Play/Pause
    call		Delay_197_ms
    call		Delay_197_ms
    call		Delay_197_ms
    call		Delay_197_ms
    bcf			PORTE,1
	
    return

PrevSong:							; ������� �� ���� �����
    call		Delay_197_ms		; ��������� ��������
    call		Delay_197_ms		
    call		Delay_197_ms
	;call		Delay_197_ms

    bsf			PORTA,4   			; Prev
    call		Delay_197_ms
    call		Delay_197_ms
    bcf			PORTE,4

    return

NextSong:							; ������� �� ���� �����
    call		Delay_197_ms		; ��������� ��������
    call		Delay_197_ms
    call		Delay_197_ms
	;call		Delay_197_ms		; ��� �� ������� ����� ����

    bsf			PORTE,2   			; Next
    call		Delay_197_ms
    call		Delay_197_ms
    bcf			PORTE,2
	
    return

TurnScreenOn:
	
    bsf			PORTE,1   			; �������� �����
    call		Delay_197_ms
    call		Delay_197_ms
    call		Delay_197_ms
    call		Delay_197_ms
    bcf			PORTE,1
 
    return


;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;||		������ � ���
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

; *******************************************************************
; *		������ ������ �� �������������� !��� 4���
; *******************************************************************

StartADC:						
    nop							; wait 5uS for A2D amp to settle and capacitor to charge.
    nop							; wait 4uS
    nop							; wait 3uS
    nop							; wait 2uS 
    nop							; wait 1uS

    bsf       	ADCON0,GO_DONE	; ������ ��������������

    return 

; *******************************************************************
; *		�������� ����������� �� ������� ����� - ������������ ������ ���
; *******************************************************************
SurfaseCheck:

	; ��� ������ ��������� ������� ������ - ����� ��� �������
    subwf		CurrentValue,w	; ������ �� ���� �������� ������� � ������� ��� � ������������
    btfss		STATUS,C		; �������� ��� ������������ - �=0 ����� �������� > �������, �=1 <= �������
    goto		VoltageUp
    goto		VoltageDown

VoltageUp:						; ������� ��������� ������������ �����������
								; ����� �� �������� ������� - ��������� � �������� ���
    sublw		b'11111111'		; �������� �� ����������� ������������� ����� �� �������
    addlw		b'00000001'		; �������� � ������� ������� ������ ������

VoltageDown:					; ������� ����� ������������ �����������
								; ����� �� �������� ������� - ��������� � ������ ����

    subwf		VoltageTreshhold,w; ������ �� �������� ������ ���������� �������� ����. � �������� ����������

    clrf		CurrentValue	; ����� �� �����, ����� ������������ ��������

    btfsc		STATUS,C		; �������� ��� ������������ - �=0 WReg > ������, �=1 <= ������
    goto		GotLine 		; <= ������ - ����� ����� �����
    goto		NoLine 			; �������� > ������	- ��� ����b

NoLine:	
    bcf			CurrentValue,0	; ������ ��� ����������� �����
	
    goto		EndSurfaseCheck	;  

GotLine:	
    bsf			CurrentValue,0	; �������� ��� ����������� �����

EndSurfaseCheck:

    return

;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;||								RS232
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

; *******************************************************************
; *		���� ������ ����� RS232
; *******************************************************************
ReceiveBit:
    btfss	PIR1,RCIF		; ���� ��� ������� � 0, �� ���-�� ���� �������
    goto 	NothingReceived
    movf	RCREG,w			; 

    movwf	RS232Received

NothingReceived:

    btfsc	RCSTA,OERR		; ������ ������������ ������
    bcf		RCSTA,OERR

    return


; *******************************************************************
; *		�������� ������ ����� RS232
; *******************************************************************
SendBit:
    bsf		STATUS,RP0		; �������� ��������� ��������
StillNotSent:					; ������� ��������, �������� �� ���������� ����
    btfss	TXSTA,TRMT		; ���� ��� ���������, �� �������� ���������
    goto	StillNotSent
    bcf		STATUS,RP0

    movwf	TXREG			; ������ ��������� ����� ����

    return


; *******************************************************************
; *		��������� ��������� �� RS232 ������������ �������
; *******************************************************************
MasterToldMe:
	
    movf      	RS232Received,w           
    xorlw     	b'00000000'				; ������� - ������ �� ���� ������!
    btfss     	STATUS,Z     
    goto      	VladDataExchangeStart
    goto      	OrderExecuted 

VladDataExchangeStart:
    movf      	RS232Received,w           
    xorlw     	b'11111111'				; ������������� �����
    btfss     	STATUS,Z     
    goto      	IfRS232Forward

    call		VladDataExchange		; ��������� �������� ������

    clrf		RS232Received			; ����� �� ���� ����������� �������� ���������� ����� � ��� �� �������

    goto      	OrderExecuted 

IfRS232Forward:
    movf      	RS232Received,w           
    xorlw     	'8'
    btfss     	STATUS,Z     
    goto      	IfRS232Backward

    call      	L_FORWARD_R_FORWARD   	; �������� �����

    clrf		RS232Received			; ����� �� ���� ����������� �������� ���������� ����� � ��� �� �������

    goto      	OrderExecuted  
  
IfRS232Backward:
    movf      	RS232Received,w           
    xorlw     	'2'
    btfss     	STATUS,Z     
    goto      	IfRS232ForwardAndLeft

    call      	L_BACKWARD_R_BACKWARD 	; �������� �����

    clrf		RS232Received			; ����� �� ���� ����������� �������� ���������� ����� � ��� �� �������

    goto      	OrderExecuted

IfRS232ForwardAndLeft:
    movf      	RS232Received,w           
    xorlw     	'7' 
    btfss     	STATUS,Z     
    goto      	IfRS232ForwardAndRight

    call      	L_STOP_R_FORWARD 		; ������� ����� �����
    call		Delay_197_ms
    call      	L_STOP_R_STOP 			; ���������

    clrf		RS232Received			; ����� �� ���� ����������� �������� ���������� ����� � ��� �� �������

    goto      	OrderExecuted
    
IfRS232ForwardAndRight:
    movf      	RS232Received,w           
    xorlw     	'9'
    btfss     	STATUS,Z     
    goto      	IfRS232BackwardAndLeft

    call      	L_FORWARD_R_STOP 		; ������� ����� ������
    call		Delay_197_ms
    call      	L_STOP_R_STOP 			; ���������

    clrf		RS232Received			; ����� �� ���� ����������� �������� ���������� ����� � ��� �� �������

    goto      	OrderExecuted

IfRS232BackwardAndLeft:
    movf      	RS232Received,w           
    xorlw     	'1'
    btfss     	STATUS,Z     
    goto      	IfRS232BackwardAndRight

    call      	L_STOP_R_BACKWARD 		; ������� ����� �����
    call		Delay_197_ms
    call      	L_STOP_R_STOP 			; ���������

    clrf		RS232Received			; ����� �� ���� ����������� �������� ���������� ����� � ��� �� �������

    goto      	OrderExecuted

IfRS232BackwardAndRight:
    movf      	RS232Received,w           
    xorlw     	'3'
    btfss     	STATUS,Z     
    goto      	IfRS232TurnConterClockwise

    call      	L_BACKWARD_R_STOP 		; ������� ����� ������
    call		Delay_197_ms
    call      	L_STOP_R_STOP 			; ���������

    clrf		RS232Received			; ����� �� ���� ����������� �������� ���������� ����� � ��� �� �������

    goto      	OrderExecuted

IfRS232TurnConterClockwise:
    movf      	RS232Received,w           
    xorlw    	'6'
    btfss     	STATUS,Z     
    goto      	IfRS232TurnClockwise

    call      	L_BACKWARD_R_FORWARD  	; �������� �� ����� ������ ������� �������
    call		Delay_197_ms
    call      	L_STOP_R_STOP 			; ���������

    clrf		RS232Received			; ����� �� ���� ����������� �������� ���������� ����� � ��� �� �������

    goto      	OrderExecuted

IfRS232TurnClockwise:
    movf      	RS232Received,w           
    xorlw     	'4'
    btfss     	STATUS,Z     
    goto      	IfRS232Stop

    call      	L_FORWARD_R_BACKWARD  	; �������� �� ����� �� ������� �������
    call		Delay_197_ms
    call      	L_STOP_R_STOP 			; ���������

    clrf		RS232Received			; ����� �� ���� ����������� �������� ���������� ����� � ��� �� �������

    goto      	OrderExecuted    

IfRS232Stop:
    movf      	RS232Received,w           
    xorlw     	'5'
    btfss     	STATUS,Z   
    goto      	IfRS232ManualOperation	; ������ ������ ����. ���������� ������ �� �������� ��������

    call      	L_STOP_R_STOP 			; ���������

    clrf		RS232Received			; ����� �� ���� ����������� �������� ���������� ����� � ��� �� �������

    goto      	OrderExecuted


IfRS232ManualOperation:					; ������ ���������� �� RS232
    movf      	RS232Received,w           
    xorlw     	'm'
    btfss     	STATUS,Z     
    goto      	IfRS232AutomaticOperation

    bsf			LineState,6				;

    clrf		RS232Received			; ����� �� ���� ����������� �������� ���������� ����� � ��� �� �������

    goto      	OrderExecuted 

IfRS232AutomaticOperation:				; �������������� ������ �������
    movf      	RS232Received,w           
    xorlw     	'a'
    btfss     	STATUS,Z     
    goto      	IfRS232PlayPauseSong

    bcf			LineState,6				;

    clrf		RS232Received			; ����� �� ���� ����������� �������� ���������� ����� � ��� �� �������

    goto      	OrderExecuted 

IfRS232PlayPauseSong:					; ��������������� ��������� �������
    movf      	RS232Received,w           
    xorlw     	'p'
    btfss     	STATUS,Z     
    goto      	IfRS232SendSensorData

    call		PlaySong
	
    clrf		RS232Received			; ����� �� ���� ����������� �������� ���������� ����� � ��� �� �������

    goto      	OrderExecuted 

IfRS232SendSensorData:					; ����� ��������� �������� �������� ���������
    movf      	RS232Received,w           
    xorlw     	'd'
    btfss     	STATUS,Z     
    goto      	OrderExecuted

;    movlw		b'10000001' 
;    call		SendBit 

;	movf		LineLeftDebug,w
;    call		SendBit 

;	movf		LineLeft,w
 ;   call		SendBit 

;	movf		LineMiddleLeftDebug,w
;    call		SendBit 

;	movf		LineMiddleLeft,w
;    call		SendBit 

;	movf		LineMiddleRightDebug,w
;    call		SendBit 

;	movf		LineMiddleRight,w
;    call		SendBit 

;	movf		LineRightDebug,w
;    call		SendBit 

;	movf		LineRight,w
;    call		SendBit 

;    movlw		b'10000001' 
;    call		SendBit 

;	movf		VoltageTreshhold,w
;    call		SendBit 

; ��������
;    movlw		b'10000001' 
;    call		SendBit 

    movf		LineState,w
    call		SendBit 

    movf		Barriers,w
    call		SendBit 

;    movlw		b'10000001' 
;    call		SendBit 


    clrf		RS232Received			; ����� �� ���� ����������� �������� ���������� ����� � ��� �� �������

    goto      	OrderExecuted 

OrderExecuted:	; ������ ������� ���������

    return


; *******************************************************************
; *		�������� ������ � ������ �����
; *******************************************************************
VladDataExchange:

;		MessageStart			; b'11111111'- ������ ���� � �� ��, �������������
;		MessageParams			; b'11xxxxxx'- <7:6> - ������ b'11', <5:2> - ����� ���������, <1:0> - ��������
;		Byte0					; �������� ������ � ������ ����� 
;		Byte1					; �������� 16 ���� ������ �� ���
;		Byte2					;
;		Byte3					; 
;		Byte4					;
;		Byte5					;
;		Byte6					;
;		Byte7					;
;		Byte8					;
;		Byte9					;
;		Byte10					;
;		Byte11					;
;		Byte12					;
;		Byte13					;
;		Byte14					;
;		Byte15					;
;		MessageEnd				; '#' - ������ ���� � �� ��, ����� ��������
;		MessageLength			; ����� ��������� ��� ��������� �� �����������

	
    movlw		RS232Received	; �� �����������, ��� ��� ������������ ����� ����� ���������

    call		ReceiveBit		; ������ ����

    movlw		RS232Received	; �� �����������, ��� ��� ������������ ����� ����� ���������

    movwf		MessageParams	; ��������� ����������� �������

;	movwf		MessageLength	; ����� ����������� �������

;	rrf			MessageLength,f	; ������� ������ �� 2 ����
;	rrf			MessageLength,f

    movlw		b'00001111'		; ������� ����� ���������
    andwf		MessageLength,f

    movlw		0x36			; ����� Byte0
    movwf		FSR				; ��������� ���������

    clrf		MessageLength

	; �������� ������


ReceiveMessage:					; ������ ���� ���������
	
    call		ReceiveBit		; ������ ���� 

    incf		MessageLength	; ������� �������� ������

    xorlw     	b'10001'		; 18 ���� ���� ������ (17� - ����������)
    btfsc     	STATUS,Z     
    goto      	EndVladDataExchange	; ���� ������� ������ 16 ������, ������ ����

    movf		RS232Received,w	; 

    movwf		INDF			; �������� ���������� ���� � ��������� ��������
    incf		FSR 			; �������� �����

	; ���������, ��� �� ���� � ��������� ������ - ����������� ����� ��� ������ ��������

	; �������� ����������� �� 16 �������� - ������ 16 - �������� ������!

    xorlw     	'#'				; ������� ������ ����� ���������?
    btfss     	STATUS,Z     	
    goto		ReceiveMessage	; ���, ��������� ����	

    decf		MessageLength	; ��������� ��� ������ ��������, �� ��� �� ���������

    movlw		0x36			; ����� Byte0
    movwf		FSR				; ��������� ���������

    clrf		RS232Received	; ����� �� ���� ���������� ������ ����-����

ProcessWhatYouReceived:

SS:
    movf      	INDF,w        			; Byte0
    xorlw     	'S'
    btfss     	STATUS,Z     
    goto      	FF

    incf		FSR 					; �������� �����

    movf      	INDF,w        			; Byte1
    xorlw     	'S'
    btfss     	STATUS,Z     
    goto      	EndVladDataExchange		; ��� ����� �������

    call      	L_STOP_R_STOP 			; ���������

    goto      	EndVladDataExchange 
	
; ====== ������� ��� �������� �����
FF:
    movf      	INDF,w        			; Byte0
    xorlw     	'F'
    btfss     	STATUS,Z     
    goto      	BB

    incf		FSR 					; �������� �����

    movf      	INDF,w        			; Byte1
    xorlw     	'F'
    btfss     	STATUS,Z     
    goto      	FR						; 

	; ��������� �����

    call      	L_FORWARD_R_FORWARD   	; �������� �����

    goto      	EndVladDataExchange 

FR:
    movf      	INDF,w        			; Byte1
    xorlw     	'R'
    btfss     	STATUS,Z     
    goto      	FL						; 

	; ��������� ����� � ������� �� ���. ����

    call      	L_FORWARD_R_STOP 		; ������� ����� ������
    call		Delay_197_ms
    call      	L_STOP_R_STOP 			; ���������

    goto      	EndVladDataExchange 

FL:
    movf      	INDF,w        			; Byte1
    xorlw     	'L'
    btfss     	STATUS,Z     
    goto      	FR90					; 

	;  ��������� ����� � ������ �� ���. ����

    call      	L_STOP_R_FORWARD 		; ������� ����� �����
    call		Delay_197_ms
    call      	L_STOP_R_STOP 			; ���������

    goto      	EndVladDataExchange 

FR90:
    movf      	INDF,w        			; Byte1
    xorlw     	'+'
    btfss     	STATUS,Z     
    goto      	FL90					; 

	; ��������� ����� � ������� �� 90 ��������

    call      	L_FORWARD_R_STOP 		; ������� ����� ������

    call		Delay_1_sec
    call		Delay_1_sec

    call		Delay_197_ms
    call		Delay_197_ms

    call      	L_STOP_R_STOP 			; ���������

    goto      	EndVladDataExchange 

FL90:
    movf      	INDF,w        			; Byte1
    xorlw     	'-'
    btfss     	STATUS,Z     
    goto      	ErrorFound				; ��� ����� �������

	; ��������� ����� � ������ �� 90 ��������

    call      	L_STOP_R_FORWARD 		; ������� ����� �����

    call		Delay_1_sec
    call		Delay_1_sec

    call		Delay_197_ms
    call		Delay_197_ms

    call      	L_STOP_R_STOP 			; ���������

    goto      	EndVladDataExchange 


; ====== ������� ��� �������� �����
BB:
    movf      	INDF,w        			; ��������������� �������������� ���������� �����   
    xorlw     	'B'
    btfss     	STATUS,Z     
    goto      	TankStyleRight

    incf		FSR 					; �������� �����

    movf      	INDF,w        			; Byte1
    xorlw     	'B'
    btfss     	STATUS,Z     
    goto      	BR				; 

	; ������ �����

    call      	L_BACKWARD_R_BACKWARD 	; �������� �����

    goto      	EndVladDataExchange 

BR:
    movf      	INDF,w        			; Byte1
    xorlw     	'R'
    btfss     	STATUS,Z     
    goto      	BL						; 

	; ��������� ����� � ������� �� ���. ����

    call      	L_BACKWARD_R_STOP 		; ������� ����� ������
    call		Delay_197_ms
    call      	L_STOP_R_STOP 			; ���������

    goto      	EndVladDataExchange 

BL:
    movf      	INDF,w        			; Byte1
    xorlw     	'L'
    btfss     	STATUS,Z     
    goto      	BR90					; 

	; ��������� ����� � ������ �� ���. ����

    call      	L_STOP_R_BACKWARD 		; ������� ����� �����
    call		Delay_197_ms
    call      	L_STOP_R_STOP 			; ���������

    goto      	EndVladDataExchange 

BR90:
    movf      	INDF,w        			; Byte1
    xorlw     	'+'
    btfss     	STATUS,Z     
    goto      	BL90				; 

	; ��������� ����� � ������� �� 90 ��������

    call      	L_BACKWARD_R_STOP 		; ������� ����� ������

    call		Delay_1_sec
    call		Delay_1_sec

    call		Delay_197_ms
    call		Delay_197_ms

    call      	L_STOP_R_STOP 			; ���������

    goto      	EndVladDataExchange 

BL90:
    movf      	INDF,w        			; Byte1
    xorlw     	'-'
    btfss     	STATUS,Z     
    goto      	ErrorFound				; ��� ����� �������

	; ��������� ����� � ������ �� 90 ��������

    call      	L_STOP_R_BACKWARD 		; ������� ����� �����

    call		Delay_1_sec
    call		Delay_1_sec

    call		Delay_197_ms
    call		Delay_197_ms

    call      	L_STOP_R_STOP 			; ���������

    goto      	EndVladDataExchange 

; ====== �������� ������
TankStyleRight:
    movf      	INDF,w        			; Byte0
    xorlw     	'R'						; �������� ������ ������
    btfss     	STATUS,Z     
    goto      	TankStyleLeft

    incf		FSR 					; �������� �����

    movf      	INDF,w        			; Byte1
    xorlw     	'T'
    btfss     	STATUS,Z     
    goto      	R9				; 

	; ��������� ������� �� ���. ����, ��������� ������� ��������

    call      	L_FORWARD_R_BACKWARD  	; �������� �� ����� �� ������� �������
    call		Delay_197_ms
    call      	L_STOP_R_STOP 			; ���������

    goto      	EndVladDataExchange 

R9:
    movf      	INDF,w        			; Byte1
    xorlw     	'9'
    btfss     	STATUS,Z     
    goto      	RR				; 

	; ��������� ������� �� 90 ��������, ��������� ������� ��������

    call      	L_FORWARD_R_BACKWARD  	; �������� �� ����� �� ������� �������

    call		Delay_1_sec
    call		Delay_1_sec

    call		Delay_197_ms
    call		Delay_197_ms

    call      	L_STOP_R_STOP 			; ���������

    goto      	EndVladDataExchange 

RR:
    movf      	INDF,w        			; Byte1
    xorlw     	'R'
    btfss     	STATUS,Z     
    goto      	ErrorFound				; ��� ����� �������

	; ��������� ������� �� 180 ��������, ��������� ������� ��������

    call      	L_FORWARD_R_BACKWARD  	; �������� �� ����� �� ������� �������

    call		Delay_1_sec
    call		Delay_1_sec

    call		Delay_197_ms
    call		Delay_197_ms

    call		Delay_1_sec
    call		Delay_1_sec

    call		Delay_197_ms
    call		Delay_197_ms

    call      	L_STOP_R_STOP 			; ���������

    goto      	EndVladDataExchange 

TankStyleLeft
    movf      	INDF,w        			; Byte0
    xorlw     	'L'						; �������� ������ ������
    btfss     	STATUS,Z     
    goto      	GetData

    incf		FSR 					; �������� �����

    movf      	INDF,w        			; Byte1
    xorlw     	'T'
    btfss     	STATUS,Z     
    goto      	L9				; 

	; ��������� ������ �� ���. ����, ��������� ������� ��������

    call      	L_BACKWARD_R_FORWARD  	; �������� �� ����� ������ ������� �������
    call		Delay_197_ms
    call      	L_STOP_R_STOP 			; ���������

    goto      	EndVladDataExchange 

L9:
    movf      	INDF,w        			; Byte1
    xorlw     	'9'
    btfss     	STATUS,Z     
    goto      	LL				; 

	; ��������� ������ �� 90 ��������, ��������� ������� ��������

    call      	L_BACKWARD_R_FORWARD  	; �������� �� ����� ������ ������� �������

    call		Delay_1_sec
    call		Delay_1_sec

    call		Delay_197_ms
    call		Delay_197_ms

    call      	L_STOP_R_STOP 			; ���������

    goto      	EndVladDataExchange 

LL:
    movf      	INDF,w        			; Byte1
    xorlw     	'L'
    btfss     	STATUS,Z     
    goto      	ErrorFound				; ��� ����� �������

	; ��������� ������ �� 180 ��������, ��������� ������� ��������

    call      	L_BACKWARD_R_FORWARD  	; �������� �� ����� ������ ������� �������

    call		Delay_1_sec
    call		Delay_1_sec

    call		Delay_197_ms
    call		Delay_197_ms

    call		Delay_1_sec
    call		Delay_1_sec

    call		Delay_197_ms
    call		Delay_197_ms

    call      	L_STOP_R_STOP 			; ���������

    goto      	EndVladDataExchange 


GetData:
    movf      	INDF,w        			; Byte0
    xorlw     	'G'
    btfss     	STATUS,Z     
    goto      	ErrorFound				; ��� ����� �������

    incf		FSR 					; �������� �����

    movf      	INDF,w        			; Byte1
    xorlw     	'D'
    btfss     	STATUS,Z     
    goto      	ErrorFound				; ��� ����� �������

	; �������� ������ � ������� ��������� ��������

    movlw		b'11010100'
    movwf		MessageParams

    movf		MessageStart,w
    call		SendBit
    movf		MessageParams,w
    call		SendBit
    movf		LineState,w
    call		SendBit
    movf		Barriers,w
    call		SendBit
    movf		MessageEnd,w
    call		SendBit

    goto      	EndVladDataExchange 

ErrorFound:								; ������ �������� �� ���������� ������� �� �������


EndVladDataExchange:
	
    return


; *******************************************************************
; *		��������� ������������� 
; *******************************************************************
WelcomeMessage:

    movlw  'M' 
    call SendBit 
    movlw  'u' 
    call SendBit 
    movlw  'l' 
    call SendBit
    movlw  't' 
    call SendBit  
    movlw  'y' 
    call SendBit 
    movlw  ' ' 
    call SendBit 
    movlw  'f'  	
    call SendBit 
    movlw  'u'
    call SendBit
    movlw  'n' 
    call SendBit
    movlw  'c' 
    call SendBit 
    movlw  't' 
    call SendBit  
    movlw  'i' 
    call SendBit 
    movlw  'o' 
    call SendBit 
    movlw  'n' 
    call SendBit 
    movlw  ' ' 
    call SendBit 
    movlw  'm' 
    call SendBit 
    movlw  'o'
    call SendBit 
    movlw  'b' 
    call SendBit
    movlw  'i' 
    call SendBit 
    movlw  'l' 
    call SendBit         
    movlw  'e' 
    call SendBit 
    movlw  ' ' 
    call SendBit 
    movlw  'p' 
    call SendBit
    movlw  'l' 
    call SendBit
    movlw  'a' 
    call SendBit
    movlw  't' 
    call SendBit 
    movlw  'f' 
    call SendBit 
    movlw  'o' 
    call SendBit 
    movlw  'r' 
    call SendBit 
    movlw  'm' 
    call SendBit 
    movlw  ' ' 
    call SendBit 
    movlw  'v' 
    call SendBit 
    movlw  '1' 
    call SendBit 
    movlw  '.' 
    call SendBit 
    movlw  '0' 
    call SendBit 
    call EndLine

    movlw  'I' 
    call SendBit 
    movlw  ' ' 
    call SendBit 
    movlw  'a' 
    call SendBit
    movlw  'm' 
    call SendBit  
    movlw  ' ' 
    call SendBit 
    movlw  'y'  	
    call SendBit 
    movlw  'o'
    call SendBit
    movlw  'u' 
    call SendBit
    movlw  'r' 
    call SendBit 
    movlw  ' ' 
    call SendBit  
    movlw  'g' 
    call SendBit 
    movlw  'u' 
    call SendBit 
    movlw  'i' 
    call SendBit 
    movlw  'd' 
    call SendBit 
    movlw  'e' 
    call SendBit 
    movlw  ' ' 
    call SendBit 
    movlw  'o'
    call SendBit 
    movlw  'n' 
    call SendBit
    movlw  ' ' 
    call SendBit 
    movlw  'k' 
    call SendBit         
    movlw  '.' 
    call SendBit 
    movlw  '3' 
    call SendBit 
    movlw  '0' 
    call SendBit
    movlw  '4' 
    call SendBit

    call EndLine

    return 

; *******************************************************************
; *		�������� ����� ������
; *******************************************************************
EndLine:
    movlw  0x0D ; CR 
    call SendBit 
    movlw  0x0A ; LF 
    call SendBit 
		
    return       


;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;||		������������ ���������� �����������
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

; *******************************************************************
; *		��������� ����������� �������� ��������
; *******************************************************************

L_STOP_R_STOP: ; ���������

    bcf			SpaceOptions,0			; �� ���� �����!

    bsf			PORTD,0      			; ��� ����������� ������� �������� � "1" 				
    bsf			PORTD,1					; ��� ��������� ���������� ��� ������� ���������
    bsf			PORTD,2				
    bsf			PORTD,3						
	
    clrf		CCPR2L					; ���������� ���. ������  = 0%	
    clrf		CCPR1L					; ���������� ��. ������ = 0%	
	
    return

L_FORWARD_R_FORWARD: ; �������� �����

    bcf			SpaceOptions,0			; �� ���� �����!

    call		L_HiSpeed
    call		R_HiSpeed

    bsf			PORTD,0      			; ����. 	
    bcf			PORTD,1			
    bsf			PORTD,2					; ���.
    bcf			PORTD,3						

    return

L_BACKWARD_R_BACKWARD: ; �������� �����

    bsf			SpaceOptions,0			; ��� ��� ���� �����!

    call		L_HiSpeed
    call		R_HiSpeed

    bcf			PORTD,0      			; ����.	
    bsf			PORTD,1						
    bcf			PORTD,2					; ���.
    bsf			PORTD,3						

    return

L_STOP_R_FORWARD: ; ������� ����� ����� 

    call		R_HiSpeed

    bcf			SpaceOptions,0			; �� ���� �����!

    bsf			PORTD,0      			; ����.	
    bsf			PORTD,1					
    bsf			PORTD,2				
    bcf			PORTD,3					; ���.	

    return

L_FORWARD_R_STOP: ; ������� ����� ������

    call		L_HiSpeed

    bcf			SpaceOptions,0			; �� ���� �����!

    bsf			PORTD,0      			; ����.	
    bcf			PORTD,1				
    bsf			PORTD,2					; ���.
    bsf			PORTD,3						

    return

L_STOP_R_BACKWARD: ; ������� ����� �����
	
    call		R_HiSpeed

    bcf			SpaceOptions,0			; �� ���� �����!

    bsf			PORTD,0      			; ����.	
    bsf			PORTD,1	
    bcf			PORTD,2					; ���.
    bsf			PORTD,3

    return

L_BACKWARD_R_STOP: ; ������� ����� ������
	
    call		L_HiSpeed

    bcf			SpaceOptions,0			; �� ���� �����!

    bcf			PORTD,0      			; ����.	
    bsf			PORTD,1
    bsf			PORTD,2					; ���.
    bsf			PORTD,3

    return

L_BACKWARD_R_FORWARD: ; �������� �� ����� ������ ������� �������
	
    call		L_HiSpeed
    call		R_HiSpeed

    bcf			SpaceOptions,0			; �� ���� �����!

    bcf			PORTD,0      			; ����.	
    bsf			PORTD,1			
    bsf			PORTD,2					; ���.
    bcf			PORTD,3

    return

L_FORWARD_R_BACKWARD: ; �������� �� ����� �� ������� �������
	
    call		L_HiSpeed
    call		R_HiSpeed

    bcf			SpaceOptions,0			; �� ���� �����!

    bsf			PORTD,0      			; ����.		
    bcf			PORTD,1	
    bcf			PORTD,2					; ���.
    bsf			PORTD,3

    return

; *******************************************************************
; *		������������ ����� ��� - ��������� ����������
; *******************************************************************
CheckPWMTimer:

    btfsc		PIR1,TMR2IF		; ���������� ������� ��� ������������ ������� ���
    bcf			PIR1,TMR2IF

    return

; *******************************************************************
; *		��������� ���������� ��� = ��������� ��� ����������
; *******************************************************************

; ����� / ������
R_HiSpeed:

    movlw		b'10000000'		; ����� ���������� - 50%
    movwf		CCPR1L			; ������ ����� �������� ����������

    return

; ����� / �����
L_HiSpeed:

    movlw		b'10000000'		; ����� ���������� - 50%
    movwf		CCPR2L			; ������ ����� �������� ����������

    return

; ===== � �������� �������� �������� ����� - �� ������� ��������, ������ �� ������������
; ��������� / ������
R_LowSpeed:
		
    movlw		b'01100110'		; ���������� 40%
    movwf		CCPR1L			; ������ ����� �������� ����������

    return

; ��������� / �����
L_LowSpeed:

    movlw		b'01100110'		; ���������� 40%
    movwf		CCPR2L			; ������ ����� �������� ����������

    return


;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;||					����������� ��������
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

; *******************************************************************
; *		�������� 1 �������
; *******************************************************************
Delay_1_sec:
	

    clrf 	   Delay1
    clrf 	   Delay2

;	 movlw     0x32            ; ��� 10 ���
;	 movlw     0x1E            ; ��� 6 ���
    movlw     0x5             ; ��� 1 ���

    movwf     Delay

OneSdelay:
    decfsz    Delay1,f
    goto      OneSdelay
    decfsz    Delay2,f
    goto      OneSdelay
    decfsz    Delay,f
    goto      OneSdelay

    return

; *******************************************************************
; *		�������� 6 ������
; *******************************************************************
Delay_6_sec:
	
	; 0x32 - ��������� ����

    clrf 	   Delay1
    clrf 	   Delay2

;	 movlw     0x32            ; ��� 10 ���
    movlw     0x1E            ; ��� 6 ���

    movwf     Delay

SixSdelay:
    decfsz    Delay1,f
    goto      SixSdelay
    decfsz    Delay2,f
    goto      SixSdelay
    decfsz    Delay,f
    goto      SixSdelay

    return

; *******************************************************************
; *		�������� 197 ����������
; *******************************************************************
Delay_197_ms:
    decfsz    Delay1,f            ; Waste time.  
    goto      Delay_197_ms        	; The Inner loop takes 3 instructions per loop * 256 loops = 768 instructions
    decfsz    Delay2,f            ; The outer loop takes and additional 3 instructions per lap * 256 loops
    goto      Delay_197_ms        	; (768+3) * 256 = 197376 instructions / 1M instructions per second = 0.197 sec.
                                   ; call it two-tenths of a second.
    return 

; *******************************************************************
; *		�������� 1 �����������
; *******************************************************************
Delay_1_ms:
    movlw     .71                 ; delay ~1000uS
    movwf     Delay
    decfsz    Delay,f             ; this loop does 215 cycles
    goto      $-1          
    decfsz    Delay,f             ; This loop does 786 cycles
    goto      $-1

    return

; *******************************************************************
; *		�������� 5 ����������
; *******************************************************************
Delay_5_ms:

    movlw     0x5             	  ; 
    movwf     Delay1
    call	   Delay_1_ms
    decfsz    Delay1,f          
    goto      $-2       
                                   
    return

; *******************************************************************
; *		������ �������� ���� - 2 ��
; *******************************************************************
ShortBeep:
    clrf 		Delay1
    clrf 		Delay2

Beep:
    btfss		PORTC,0
    goto 		Rise
    bcf		PORTC,0
    goto		NextBeep
Rise:
    bsf		PORTC,0
NextBeep:
    decfsz     Delay1,f   
    goto      Beep
    decfsz    Delay2,f            
    goto      Beep
                                   
    return

    end
; **********************************************************************
;========================����� ��������� ��������=======================
; **********************************************************************