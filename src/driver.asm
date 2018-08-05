; *******************************************************************
; *		
; *		Мозгунов Дмитрий Юрьевич. гр03-621
; *		2009-2010гг.
; *		
; *******************************************************************

#include <p16F887.inc>
    __CONFIG    _CONFIG1, _LVP_OFF & _FCMEN_OFF & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_ON & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
    __CONFIG    _CONFIG2, _WRT_OFF & _BOR21V


    cblock 0x20
		RS232Received			; принятый по RS232 бит
		
		Delay				; 
		Delay1				; Генерация задержек
		Delay2				;

		Barriers			; препятствия на основе датчиков препятствий
		LineCount			; количество перпендикулярных линий при навигации

		LineLeft			; базовое значение c крайнего левого приёмника датчика линии  
		LineMiddleLeft		        ; базовое значение c среднего левого приёмника датчика линии  
		LineMiddleRight			; базовое значение c среднего правого приёмника датчика линии  
		LineRight			; базовое значение c крайнего правого приёмника датчика линии  

		LineState			; 4 младших бита - датчик линии, 4 старших опции, рассмотрены ниже
		CurrentValue			; базовое значение, передаваемое в подпрограмму обработки данных АЦП
								; возвращает наличие/отсутствие линии!!!!
								; используется для хранения данных по линии после обработки АЦП
		VoltageTreshhold		; мин. изменение напряжения при сходе с линии

		ButtonPushCounter		; обработка дребезга контактов для "усов"
		StableStateCounter		; обработка дребезга контактов для "усов"

		NextSongNumber			; номер следующей для воспроизведения мелодии 
		CurrentSongNumber		; номер мелодии уже воспроизведенной мелодии (её начало)
		SpaceOptions			; параметры окружающего пространства

		CycleCounterL			; счётчик циклов Таймера0. Младшая часть
		CycleCounterH			; счётчик циклов Таймера0. Старшая часть

		MessageStart			; b'11111111'- всегда одно и то же, инициализация
		MessageParams			; b'11xxxxxx'- <7:6> - всегда b'11', <5:2> - длина сообщения, <1:0> - контроль
		Byte0				; протокол обмена с прогой Влада 
		Byte1				; максимум 16 байт данных за раз
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
		MessageEnd			; '#' - всегда одно и то же, конец передачи
		MessageLength			; длина сообщения для установки из подпрограмм
		

		LineLeftDebug
		LineMiddleLeftDebug
		LineMiddleRightDebug
		LineRightDebug

    endc

    org 0
    
Start:

; *******************************************************************
; *		начальные установки портов ввода-вывода
; *******************************************************************
;
;--------------  Bank 1 --------------
    bsf       	STATUS,RP0		; Выбор Register Bank 1 

; Порт A 
    movlw		b'00001111'
    movwf		TRISA         	; RA0, RA1, RA2, RA3 - входы АЦП. RA6, RA7 - Кварц

; Порт B
    movlw		b'00011111'
    movwf   	TRISB			; RB0, RB1, RB2, RB3, RB4 - входы, кнопки

; Порт C
    movlw		b'10000000'
    movwf   	TRISC			; RC7 - вход - Rx, RC6 - выход - Tx,  
					; RC1 и RC2 - выходы ШИМ
 
; Порт D 
    movlw		b'11110000'	; RD0-RD3 - выходы, управление двигателями
    movwf   	TRISD			; RD4-RD7 - входы с датчиков препятствий

; Порт E 
    clrf		TRISE		; <0:2> - выходы
    bsf			TRISE,3		; MCLR

    movlw		b'00000100'    ; сконфигурируем Timer0.
    movwf		OPTION_REG     ; прескейлер 1:32

;АЦП 
    movlw     	0x00			; Left Justified, Vdd-Vss referenced
    movwf     	ADCON1

; ШИМ
    movlw	   	0x65		; частота 0,6КГц
    movwf	   	PR2

; RS232
; паритет = 0, стоповый бит = 1
;	movlw		0x0C            ; скорость 19200 килобит/с 
    movlw		0x19            ; скорость 9600 килобит/с 
    movwf		SPBRG

    movlw		b'00100100'     ; brgh = high (2)
    movwf		TXSTA           ; включим асинхронную передачу, set brgh

;--------------  Bank 3 --------------
    bsf			STATUS,RP1	; select Register Bank 3

    movlw		b'00001111'	; RA0,RA1,RA,RA3 - аналоговые входы - сканер линии
    movwf		ANSEL

    clrf  		ANSELH          ; все остальные входы - цифра

;--------------  Bank 0 --------------
    bcf			STATUS,RP0	; back to Register Bank 0
    bcf			STATUS,RP1

;==== сконфигурируем ШИМ
    clrf		CCP2CON		; отключим ШИМ левого двигателя
    clrf		CCP1CON		; отключим ШИМ правого двигателя
    clrf		TMR2		; очистка Таймера 2
    clrf		CCPR2L		; скважность = 0% левого двигателя
    clrf		CCPR1L		; скважность = 0% правого двигателя 

    movlw		b'00101100'	;
    movwf		CCP2CON		; активируем ШИМ левого двигателя
    movwf		CCP1CON		; активируем ШИМ правого двигателя 
	   	  
;==== сконфигурируем таймер ШИМ
    bcf			PIR1,TMR2IF	; очистка флага прерывания таймера
	
    clrf		T2CON		  
    bsf			T2CON,T2CKPS1	; prescaler = 16
    bsf			T2CON,TMR2ON	; активируем таймер

;==== очистим буфер АЦП и выходы RDx
    clrf		ADRESH
    bcf			PORTD,0
    bcf			PORTD,1
    bcf			PORTD,2
    bcf			PORTD,3

; === обнулим часть регистров
    clrf		RS232Received		; обнулили счётчик нажатий кнопки
    clrf		CurrentSongNumber	; счётчик песенок - играем последовательно
    clrf		Barriers		; обнулим слово состояния датчиков препятствий
    clrf		LineCount		; обнулим счётчик перпендикулярных отметок
    clrf		CycleCounterL	
    clrf		CycleCounterH

;==== управление плеером
    bcf			PORTE,0
    bcf			PORTE,1
    bcf			PORTE,2
    bcf			PORTA,4

;==== RS232
    movlw		b'10010000'		; включим асинхронный приём
    movwf		RCSTA

;==== небольшой разогрев 
    clrf 		Delay
settle:
    decfsz 		Delay,F
    goto 		settle     	

    movf 		RCREG,W 		; очистим буфер приёма
    movf 		RCREG,W
    movf 		RCREG,W    

;==== 
    bsf			PORTE,1   		; Вклюичть плеер
    call		Delay_1_sec
    call		Delay_1_sec
    bcf			PORTE,1

;====
    movlw		b'11111111'
    movwf		MessageStart
    movlw		'#'
    movwf		MessageEnd 

; *******************************************************************
; *		 основной рабочий цикл
; *******************************************************************

    call		ShortBeep	; пошипим пьезоизлучателем 
    call		WelcomeMessage	; и выдадим приветствие по RS232
    
    clrf		CurrentValue	; временная переменная на все случаи жизни

    clrf		LineState	; 4 младших бита(<0:3>) - датчик линии
					; <4> - наличие/отсутствие перпендикулярной линии - для подсчёта
					; <5> - выставлен - мы на стартовой линии
					; <6> - если выставлен, то управление по RS232 - снят - автоматическое
    bsf			LineState,7	; <7> - прогон датчиков выполнялся первый раз - определение отражательных свойств поверхности

 	; порог срабатывания датчика линии
;	movlw		b'00010100'		; 0,4B
;	movlw		b'00011001'		; 0,5B
;	movlw		b'00011110'		; 0,6B
;	movlw		b'00100011'		; 0,7B
;	movlw		b'00101000'		; 0,8B
;	movlw		b'00101101'		; 0,9B
    movlw		b'00110010'		; 1,0B
;	movlw		b'00111101'		; 1,2B
;	movlw		b'01001100'		; 1,5B
;	movlw		b'01100110'		; 2В
    movwf		VoltageTreshhold; 

    clrf		SpaceOptions	; 

    bsf			LineState,6		; изначально ждём команд по RS232
    bsf			LineState,5		; стоим на стартовой линии

    call      	L_STOP_R_STOP 	; Остановка

MainLoop:
 
LineDetectorCheck:
;========= крайний правый сенсор ==========

	; значение крайнего правого приёмника датчика линии
    movlw		b'10000001'		; RA0 (AN0)
    movwf		ADCON0 			; configure A2D for Fosc/8, and turn on the A2D module

    call		StartADC		; начали преобразование

CheckADC_LR:

    btfsc		ADCON0,GO_DONE		; бит обнулится когда закончится преобразование
    goto		CheckPWM_LR

    movf		LineRight,w		; для передачи в подпрограмму анализа
    movwf		CurrentValue

    movf		ADRESH,w		; очередное значение с АЦП

    movwf		LineRightDebug

    btfss		LineState,7	
    goto		IsNotFirstPass_LR	; 7й = 0 
						; первый проход для обнаружения поверхности 
    movwf		LineRight		; базовое значение поверхности крайнего правого приёмника датчика линии  
    goto		Sensor_LMR		; проверка следующего сенсора

IsNotFirstPass_LR:	

    call 		SurfaseCheck		; проверим очередное считанное с АЦП значение

    btfsc		CurrentValue,0		; вернули из подпрограммы данные о линии
    goto		GotLine_LR
    bcf			LineState,0		; снимем бит обнаружения линии
    goto		Sensor_LMR		; проверка следующего сенсора

GotLine_LR:

    bsf			LineState,0		; выставим бит обнаружения линии
    goto		Sensor_LMR		; проверка следующего сенсора


; проверка при оцифровке текущего значения напряжения на датчике
CheckPWM_LR:
    call 		CheckPWMTimer		; программно очищаем бит переполнения таймера ШИМ
    call 		ReceiveBit 		; проверим поступление новых команд
    call		MasterToldMe		; обработаем принятую команду

    goto		CheckADC_LR		 
	

;========= средний правый сенсор ==========

Sensor_LMR: ; значение среднего правого приёмника датчика линии

    movlw		b'10000101'		; RA1 (AN1)
    movwf		ADCON0 		

    call		StartADC		; начали преобразование

CheckADC_LMR:

    btfsc		ADCON0,GO_DONE		; бит обнулится когда закончится преобразование
    goto		CheckPWM_LMR

    movf		LineMiddleRight,w	; для передачи в подпрограмму анализа
    movwf		CurrentValue

    movf		ADRESH,w		; очередное значение с АЦП	

    movwf		LineMiddleRightDebug

    btfss		LineState,7	
    goto		IsNotFirstPass_LMR	; 7й = 0 
						; первый проход для обнаружения поверхности 
    movwf		LineMiddleRight		; базовое значение поверхности крайнего правого приёмника датчика линии  
    goto		Sensor_LML		; проверка следующего сенсора

IsNotFirstPass_LMR:	

    call 		SurfaseCheck		; проверим очередное считанное с АЦП значение

    btfsc		CurrentValue,0		; вернули из подпрограммы данные о линии
    goto		GotLine_LMR
    bcf			LineState,1		; снимем бит обнаружения линии
    goto		Sensor_LML		; проверка следующего сенсора

GotLine_LMR:

    bsf			LineState,1		; выставим бит обнаружения линии
    goto		Sensor_LML		; проверка следующего сенсора

	
CheckPWM_LMR:
    call 		CheckPWMTimer		; программно очищаем бит переполнения таймера ШИМ
    call 		ReceiveBit 		; проверим поступление новых команд
    call		MasterToldMe		; обработаем принятую команду

    goto		CheckADC_LMR		  

;========= средний левый сенсор ==========

Sensor_LML:	; значение среднего левого приёмника датчика линии  

    movlw		b'10001001'		; RA2 (AN2)
    movwf		ADCON0 			; configure A2D for Fosc/8, and turn on the A2D module

    call		StartADC		; начали преобразование

CheckADC_LML:

    btfsc		ADCON0,GO_DONE		; бит обнулится когда закончится преобразование
    goto		CheckPWM_LML

    movf		LineMiddleLeft,w	; для передачи в подпрограмму анализа
    movwf		CurrentValue

    movf		ADRESH,w		; очередное значение с АЦП 

    movwf		LineMiddleLeftDebug

    btfss		LineState,7	
    goto		IsNotFirstPass_LML	; 7й = 0 
						; первый проход для обнаружения поверхности 
    movwf		LineMiddleLeft		; базовое значение поверхности крайнего правого приёмника датчика линии  
    goto		Sensor_LL		; проверка следующего сенсора

IsNotFirstPass_LML:	

    call 		SurfaseCheck		; проверим очередное считанное с АЦП значение

    btfsc		CurrentValue,0		; вернули из подпрограммы данные о линии
    goto		GotLine_LML
    bcf			LineState,2		; снимем бит обнаружения линии
    goto		Sensor_LL		; проверка следующего сенсора

GotLine_LML:

    bsf			LineState,2		; выставим бит обнаружения линии

    goto		Sensor_LL		; проверка следующего сенсора

CheckPWM_LML:
    call 		CheckPWMTimer		; программно очищаем бит переполнения таймера ШИМ
    call 		ReceiveBit 		; проверим поступление новых команд
    call		MasterToldMe		; обработаем принятую команду

    goto		CheckADC_LML

;========= крайний левый сенсор ==========

Sensor_LL:	; пред. значение крайнего левого приёмника датчика линии  

    movlw		b'10001101'		; RA3 (AN3)
    movwf		ADCON0 			; configure A2D for Fosc/8, and turn on the A2D module
    call		StartADC		; начали преобразование

CheckADC_LL:

    btfsc		ADCON0,GO_DONE		; бит обнулится когда закончится преобразование
    goto		CheckPWM_LL

    movf		LineLeft,w		; для передачи в подпрограмму анализа
    movwf		CurrentValue

    movf		ADRESH,w		; очередное значение с АЦП

    movwf		LineLeftDebug

    btfss		LineState,7	
    goto		IsNotFirstPass_LL	; 7й = 0 
						; первый проход для обнаружения поверхности 
    movwf		LineLeft		; базовое значение поверхности крайнего правого приёмника датчика линии  
    goto		EndLineDetectorCheck	; проверка следующего сенсора

IsNotFirstPass_LL:	

    call 		SurfaseCheck		; проверим очередное считанное с АЦП значение

    btfsc		CurrentValue,0		; вернули из подпрограммы данные о линии
    goto		GotLine_LL
    bcf			LineState,3		; снимем бит обнаружения линии
    goto		EndLineDetectorCheck	; проверка следующего сенсора

GotLine_LL:

    bsf			LineState,3		; выставим бит обнаружения линии
    goto		EndLineDetectorCheck	; проверка следующего сенсора

CheckPWM_LL:
    call 		CheckPWMTimer	; программно очищаем бит переполнения таймера ШИМ
    call 		ReceiveBit      ; проверим поступление новых команд
    call		MasterToldMe	; обработаем принятую команду

    goto		CheckADC_LL		

EndLineDetectorCheck:
;========= Закончили опрос сканера линии ==========

;========= ИК датчики препятствий ==========

    movlw		b'11110000'		; выделим данные о наличии препятствий 
    andwf		PORTD,w
    movwf		Barriers

;========= Контактные датчики препятствий ==========

;CheckRightContact:
    movlw		5			; левый датчик
    movwf		StableStateCounter
    clrf		ButtonPushCounter	

Debounce0:				    ; правый
    clrw				    ; assume it's not, so clear
    btfss		PORTB,0             ; wait for switch to go low
    incf		ButtonPushCounter,w ; if it's low, bump the counter
    movwf		ButtonPushCounter   ; store either the 0 or incremented value

    decfsz		StableStateCounter,f	; счётчик цикла
    goto		Debounce0

    movf		ButtonPushCounter,w ; have we seen 5 in a row?
    xorlw		5
    btfss		STATUS,Z     
    goto		RightNotPushed

	; во что-то уткнулись
    bcf			LineState,6			; программная блокировка автокоррекции по линии с RS232
    bcf			Barriers,3			;

    goto		CheckLeftContact

RightNotPushed:
    bsf			Barriers,3			;

CheckLeftContact:					; левый датчик

    movlw		5
    movwf		StableStateCounter
    clrf		ButtonPushCounter	

Debounce1:
    clrw                            ; assume it's not, so clear
    btfss		PORTB,1             ; wait for switch to go low
    incf		ButtonPushCounter,w ; if it's low, bump the counter
    movwf		ButtonPushCounter   ; store either the 0 or incremented value

    decfsz		StableStateCounter,f; счётчик цикла
    goto		Debounce1

    movf		ButtonPushCounter,w ; have we seen 5 in a row?
    xorlw		5
    btfss		STATUS,Z     
    goto		LeftNotPushed

	; во что-то уткнулись
    bcf			LineState,6			; программная блокировка автокоррекции по линии с RS232
    bcf			Barriers,2			;

    goto		EndSensorCheck
	
LeftNotPushed:
    bsf			Barriers,2			; 

EndSensorCheck:
;========= Закончили опрос датчики препятствий ==========

    bcf			LineState,7				; первый обход завершен - освещенность поверхности определена

    btfsc		LineState,6				; программная блокировка автокоррекции по линии с RS232
    goto		MovementCorrection

    btfss		LineState,5				; если стоим на стартовой линии, надо с неё уехать!
    goto		MovementCorrection

    bcf			LineState,5				; сошли с линии

    btfss		Barriers,2
    bsf			SpaceOptions,5				; нажали левый "ус" -  стенка будет слева

    btfss		Barriers,3
    bsf			SpaceOptions,7				; нажали правый "ус" -  стенка будет справа

    bsf			Barriers,2				; левый контактник в норме - коррекция пока не нужна 
    bsf			Barriers,3				; правый контактник в норме - корекция пока не нужна
    bsf			SpaceOptions,1			; выставить флаг активации поворота по таймеру

    call		L_FORWARD_R_FORWARD 	; уедем с линии

    call		Delay_197_ms			; дадим время уехать
    call		Delay_197_ms			; дадим время уехать
    call		Delay_197_ms			; дадим время уехать

MovementCorrection:

	; сначала проверим, не сработали ли контактники
    btfsc		Barriers,2				; если выставлен - не нажат, ничего не делаем
    goto		CheckOnceMore

    call		EmergencyCorrection		

    goto		MainLoop 				; обстановка изменилась, необходимо обновить данные

CheckOnceMore:
    btfsc		Barriers,3				; если выставлен - не нажат, ничего не делаем
    goto		EverythingIsOk

    call		EmergencyCorrection		

    goto		MainLoop 				; обстановка изменилась, необходимо обновить данные


EverythingIsOk:

	; если всё хорошо, обработаем данные сканера линии
    movlw		b'00001111'				; выделим данные о наличии линии 
    andwf		LineState,w
	
    movwf		CurrentValue			; если ни один фотоэлемент не фиксирует линию
    movf		CurrentValue,f			; если будет равно 0, то будет выставлен бит Z регистра STATUS

    btfss		STATUS,Z				; проверим сей факт
    goto		LineFound
    goto		NoLineFound
	
LineFound:
    call		TrackTheLine	     	; автоуправление движением на базе датчика линии

    goto		MainLoop 

NoLineFound:
    call		CrawlingAlongTheWall	; автоуправление движением на базе датчиков препятствий

    goto		MainLoop 


;========================ПОДПРОГРАММЫ================================
; *******************************************************************
; *		Режим ползания вдоль стены - обход коридора 
; *		во время экскурсии
; *******************************************************************
CrawlingAlongTheWall:

    movfw		Barriers				; слово состояния датчиков препятствий
										; <7:2> - состояния датчиков
										; Barriers,3			;
										; <7> - задний ИК
										; <6> - правый ИК
										; <5> - средний ИК
										; <4> - левый ИК
										; <3> - правый контактник
										; <2> - левый котнактник
	
    movwf		CurrentValue			; запомним на будущее 

	; SpaceOptions						; Параметры окружения робота - препятствия, линии и тп
										; <7> - стенка была справа
										; <6> - стенка была спереди - объехав, нужно 
										; <5> - стенка была слева
										; <4> - 
										; <3> - 
										; <2> - 
										; <1> - флаг активации поворота по таймеру
										; <0> - едем назад

    bcf			LineState,4				; если мы в этом блоке, то никаих линий под роботом нет 
										; чистим бит наличия перпендикулярной линии

    btfsc		LineState,6		     	; программная блокировка автокоррекции по линии с RS232
    goto		EndCrawlingAlongTheWall ;

Crawling0:
    movf      	CurrentValue,w  
    xorlw     	b'11111100'				; нет препятствий
    btfss     	STATUS,Z     
    goto      	Crawling1
    call      	L_FORWARD_R_FORWARD   	; Движение вперёд

	; тут обработка таймера, когда надо
    btfss		SpaceOptions,1			; если стоит флаг активации поворота по таймеру, 
    goto      	EndCrawlingAlongTheWall ; не пойдём на следующий виток


	; параметры таймера после воспроизведения вернули в той же подпрограмме
    call		CheckTimer0				; проверка переполения и инкремент

    movf      	CycleCounterL,w   
    xorlw     	b'01111111'				; экспериментально подобрать время
    btfss     	STATUS,Z     
    goto      	EndCrawlingAlongTheWall 

	; едем достаточно долго чтобы развернуться и снова искать стенку
	; тут же выбор направления поворота в зависимости от прошлого расположения стенки

	; одновременно две стенки по идее быть не должны

    btfsc		SpaceOptions,7			; стенка была справа
    call      	L_FORWARD_R_STOP 		; Поворот вперёд вправо

    btfsc		SpaceOptions,5			; стенка была слева
    call      	L_STOP_R_FORWARD 		; Поворот вперёд влево

    call		Delay_197_ms			; дадим время повернуть
    call		Delay_197_ms			; дадим время повернуть
    call		Delay_197_ms			; дадим время повернуть

    goto      	EndCrawlingAlongTheWall 

Crawling1:
    movf      	CurrentValue,w  
    xorlw     	b'11101100'				; стенка слева 
    btfss     	STATUS,Z     
    goto      	Crawling2

    bcf			SpaceOptions,7			; потеряли стенку справа

    bsf			SpaceOptions,5			; нашли стенку слева
    bsf			SpaceOptions,1			; выставить флаг активации поворота по таймеру

    call      	L_FORWARD_R_STOP 		; Поворот вперёд вправо
    goto      	EndCrawlingAlongTheWall	

Crawling2:
    movf      	CurrentValue,w  
    xorlw     	b'11001100'				; стенка слева  и препятствие спереди
    btfss     	STATUS,Z     
    goto      	Crawling3

    bsf			SpaceOptions,6			; нашли стенку спереди	
    bsf			SpaceOptions,1			; выставить флаг активации поворота по таймеру

    call      	L_BACKWARD_R_BACKWARD  	; Сдадим немного назад, чтобы гусеницами за перпятствие не цепляться

    call		Delay_197_ms			; дадим время отъехать
    call		Delay_197_ms			; дадим время отъехать
    call		Delay_197_ms			; дадим время отъехать

	; надо проверить, не шарахнулись ли мы в углу - от правой стенки

    btfss		SpaceOptions,7			; была таки стенка справа - загнали нас в угол
    goto      	Crawling2Normal	
    call      	L_BACKWARD_R_FORWARD  	; Разворот на месте против часовой стрелки

    call		Delay_197_ms			; дадим время отъехать
    call		Delay_197_ms			; дадим время отъехать
    call		Delay_197_ms			; дадим время отъехать

    goto      	EndCrawlingAlongTheWall	

Crawling2Normal: 						; не было стенки справа 

    call      	L_FORWARD_R_BACKWARD  	; Разворот на месте по часовой стрелке

    call		Delay_197_ms			; дадим время отъехать
    call		Delay_197_ms			; дадим время отъехать
    call		Delay_197_ms			; дадим время отъехать

    bcf			SpaceOptions,7			; потеряли стенку справа
    bsf			SpaceOptions,5			; нашли стенку слева

    goto      	EndCrawlingAlongTheWall	

Crawling3:
    movf      	CurrentValue,w  
    xorlw     	b'10011100'				; стенка справа  и препятствие спереди
    btfss     	STATUS,Z     
    goto      	Crawling4

    bsf			SpaceOptions,6			; нашли стенку спереди	
    bsf			SpaceOptions,1			; выставить флаг активации поворота по таймеру

    call      	L_BACKWARD_R_BACKWARD  	; Сдадим немного назад, чтобы гусеницами за перпятствие не цепляться

    call		Delay_197_ms			; дадим время отъехать
    call		Delay_197_ms			; дадим время отъехать
    call		Delay_197_ms			; дадим время отъехать

    btfss		SpaceOptions,5			; была таки стенка слева - загнали нас в угол
    goto      	Crawling3Normal	
    call      	L_FORWARD_R_BACKWARD  	; Разворот на месте по часовой стрелке

    call		Delay_197_ms			; дадим время отъехать
    call		Delay_197_ms			; дадим время отъехать
    call		Delay_197_ms			; дадим время отъехать

    goto      	EndCrawlingAlongTheWall	

Crawling3Normal: 						; не было стенки слева

    call      	L_BACKWARD_R_FORWARD  	; Разворот на месте против часовой стрелки

    call 		Delay_197_ms			; дадим время развернуться
    call 		Delay_197_ms			; дадим время развернуться
    call		Delay_197_ms			; дадим время отъехать

    bcf			SpaceOptions,5			; потеряли стенку слева
    bsf			SpaceOptions,7			; нашли стенку справа

    goto      	EndCrawlingAlongTheWall	

Crawling4:

    movf      	CurrentValue,w  
    xorlw     	b'10111100'				; стенка справа
    btfss     	STATUS,Z     
    goto      	Crawling5

    bcf			SpaceOptions,5			; потеряли стенку слева

    bsf			SpaceOptions,7			; нашли стенку справа
    bsf			SpaceOptions,1			; выставить флаг активации поворота по таймеру

    call      	L_STOP_R_FORWARD 		; Поворот вперёд влево

    goto      	EndCrawlingAlongTheWall

Crawling5:
    movf      	CurrentValue,w  
    xorlw     	b'11011100'				; стенка прямо по курсу
    btfss     	STATUS,Z     
    goto      	CrawlingBack

    bsf			SpaceOptions,6			; нашли стенку спереди	

	; выбор направления поворота в зависимости от пред расположения стенки!

    call      	L_BACKWARD_R_BACKWARD  	; Сдадим немного назад, чтобы гусеницами за перпятствие не цепляться

    call		Delay_197_ms			; дадим время отъехать
    call		Delay_197_ms			; дадим время отъехать
    call		Delay_197_ms			; дадим время отъехать

    btfss		SpaceOptions,5			; была стенка слева - надо развернуться 
    call      	L_FORWARD_R_BACKWARD  	; Разворот на месте по часовой стрелке

    btfsc		SpaceOptions,7			; была стенка справа - надо развернуться 
    call      	L_BACKWARD_R_FORWARD  	; Разворот на месте против часовой стрелки

    call		Delay_197_ms			; дадим время развернуться
    call		Delay_197_ms			; дадим время развернуться
    call		Delay_197_ms			; дадим время развернуться

    bcf			SpaceOptions,5			; потеряли стенку слева
    bcf			SpaceOptions,7			; потеряли стенку справа

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
; *		обработка нажатия контактных датчиков
; *******************************************************************

EmergencyCorrection:

    movf		Barriers,w				; слово состояния датчиков препятствий
    movwf		CurrentValue			; запомним на будущее 

    movlw		b'00001100'				; выделим данные о контактниках
    andwf		CurrentValue,f

    movf		CurrentValue,f			; если всё по 0 то Z = 1	
;	movf      	CurrentValue,w  
;   xorlw     	b'00000000'				; стенка прямо по курсу - контактники
    btfss     	STATUS,Z     
    goto      	Correction1

    bsf			SpaceOptions,6			; нашли стенку спереди	

	; выбор направления поворота в зависимости от пред расположения стенки!

    call      	L_BACKWARD_R_BACKWARD  	; Сдадим немного назад, чтобы гусеницами за перпятствие не цепляться

    call		Delay_197_ms			; дадим время отъехать
    call		Delay_197_ms			; дадим время отъехать
    call		Delay_197_ms			; дадим время отъехать

    btfss		SpaceOptions,5			; была стенка слева - надо развернуться 
    call      	L_FORWARD_R_BACKWARD  	; Разворот на месте по часовой стрелке

    btfsc		SpaceOptions,7			; была стенка слева - надо развернуться 
    call      	L_BACKWARD_R_FORWARD  	; Разворот на месте против часовой стрелки

    call		Delay_197_ms			; дадим время развернуться
    call		Delay_197_ms			; дадим время развернуться
    call		Delay_197_ms			; дадим время развернуться
    call		Delay_197_ms			; дадим время развернуться

    goto      	EndEmergencyCorrection

Correction1:
    movf      	CurrentValue,w  
    xorlw     	b'00001000'				; стенка слева по курсу - контактники
    btfss     	STATUS,Z     
    goto      	Correction2

    bcf			SpaceOptions,7			; потеряли стенку справа

    bsf			SpaceOptions,5			; нашли стенку слева
    bsf			SpaceOptions,1			; выставить флаг активации поворота по таймеру

    call      	L_BACKWARD_R_BACKWARD  	; Сдадим немного назад, чтобы гусеницами за перпятствие не цепляться

    call		Delay_197_ms			; дадим время отъехать
    call		Delay_197_ms			; дадим время отъехать
    call		Delay_197_ms			; дадим время отъехать
    call		Delay_197_ms			; дадим время отъехать

    call      	L_FORWARD_R_BACKWARD  	; Разворот на месте по часовой стрелке

    call		Delay_197_ms			; дадим время отъехать
    call		Delay_197_ms			; дадим время отъехать

    goto      	EndEmergencyCorrection

Correction2:
    movf      	CurrentValue,w  
    xorlw     	b'00000100'				; стенка справа по курсу - контактники
    btfss     	STATUS,Z     
    goto      	EndEmergencyCorrection

    bcf			SpaceOptions,5			; потеряли стенку слева

    bsf			SpaceOptions,7			; нашли стенку справа
    bsf			SpaceOptions,1			; выставить флаг активации поворота по таймеру

    call      	L_BACKWARD_R_BACKWARD  	; Сдадим немного назад, чтобы гусеницами за перпятствие не цепляться

    call		Delay_197_ms			; дадим время отъехать
    call		Delay_197_ms			; дадим время отъехать
    call		Delay_197_ms			; дадим время отъехать
    call		Delay_197_ms			; дадим время отъехать

    call      	L_BACKWARD_R_FORWARD  	; Разворот на месте против часовой стрелки

    call		Delay_197_ms			; дадим время отъехать
    call		Delay_197_ms			; дадим время отъехать

EndEmergencyCorrection:

    return

; *******************************************************************
; *		скорректируем движение относительно схода с линии
; *******************************************************************
TrackTheLine:

    movlw		b'00001111'		; выделим данные о наличии линии - мало ли что будет храниться в старших битах позже
    andwf		LineState,w
	
    movwf		CurrentValue	; запомним на будущее

CheckOnceAgain:

;GoForward - изначально едем прямо
    movf      	CurrentValue,w    
    xorlw     	b'00000000'
    btfss     	STATUS,Z     
    goto      	GoForward

    btfss		LineState,6		     	; программная блокировка автокоррекции по линии с RS232
    call      	L_FORWARD_R_FORWARD   	; Движение вперёд

    btfss		LineState,4				; если бит наличия линии выставлен
    goto      	CorrectionMade

    bcf			LineState,4				; не теряя возможности снимем его

    clrf		CycleCounterL			; очистим счётчик таймера
    clrf		CycleCounterH			; 

    goto      	CorrectionMade
   
GoForward:

    movf      	CurrentValue,w  
    xorlw     	b'00000110'
    btfss     	STATUS,Z     
    goto      	GoToTheRight

    btfss		LineState,6		     	; программная блокировка автокоррекции по линии с RS232
    call      	L_FORWARD_R_FORWARD   	; Движение вперёд

    btfss		LineState,4				; если бит наличия линии выставлен
    goto      	CorrectionMade

    bcf			LineState,4				; не теряя возможности снимем его

    clrf		CycleCounterL			; очистим счётчик таймера
    clrf		CycleCounterH			; 

    goto      	CorrectionMade

GoToTheRight:

    movf      	CurrentValue,w  
    xorlw     	b'00000100'
    btfss     	STATUS,Z     
    goto      	GoToTheRight2

    btfss		LineState,6		     	; программная блокировка автокоррекции по линии с RS232
    call      	L_STOP_R_FORWARD 		; Поворот вперёд влево

    btfss		LineState,4				; 
    goto      	CorrectionMade

    bcf			LineState,4				; не теряя возможности снимем его

    clrf		CycleCounterL			; очистим счётчик таймера
    clrf		CycleCounterH			; 

    goto      	CorrectionMade

GoToTheRight2:

    movf      	CurrentValue,w  
    xorlw     	b'00001100'
    btfss     	STATUS,Z     
    goto      	GoToTheRightFast

    btfss		LineState,6		     	; программная блокировка автокоррекции по линии с RS232
    call      	L_BACKWARD_R_FORWARD  	; Разворот на месте против часовой стрелки

;	btfss		LineState,4				; если бит наличия линии выставлен
;	goto      	CorrectionMade

;	bcf			LineState,4				; не теряя возможности снимем его

;	clrf		CycleCounterL			; очистим счётчик таймера
;	clrf		CycleCounterH			; 

    goto      	CorrectionMade

GoToTheRightFast:

    movf      	CurrentValue,w  
    xorlw     	b'00001000'
    btfss     	STATUS,Z     
    goto      	GoToTheLeft

    btfss		LineState,6		     	; программная блокировка автокоррекции по линии с RS232
    call      	L_BACKWARD_R_FORWARD  	; Разворот на месте против часовой стрелки

    btfss		LineState,4				; если бит наличия линии выставлен
    goto      	CorrectionMade

    bcf			LineState,4				; не теряя возможности снимем его

    clrf		CycleCounterL			; очистим счётчик таймера
    clrf		CycleCounterH			; 

    goto      	CorrectionMade

GoToTheLeft:

    movf      	CurrentValue,w  
    xorlw     	b'00000010'
    btfss     	STATUS,Z     
    goto      	GoToTheLeft2

    btfss		LineState,6		     	; программная блокировка автокоррекции по линии с RS232
    call      	L_FORWARD_R_STOP 		; Поворот вперёд вправо


    btfss		LineState,4				; если бит наличия линии выставлен
    goto      	CorrectionMade

    bcf			LineState,4				; не теряя возможности снимем его

    clrf		CycleCounterL			; очистим счётчик таймера
    clrf		CycleCounterH			; 

    goto      	CorrectionMade

GoToTheLeft2:

    movf      	CurrentValue,w  
    xorlw     	b'00000011'
    btfss     	STATUS,Z     
    goto      	GoToTheLeftFast

    btfss		LineState,6		     	; программная блокировка автокоррекции по линии с RS232
    call      	L_FORWARD_R_BACKWARD  	; Разворот на месте по часовой стрелке


;	btfss		LineState,4				; если бит наличия линии выставлен
;	goto      	CorrectionMade

;	bcf			LineState,4				; не теряя возможности снимем его

;	clrf		CycleCounterL			; очистим счётчик таймера
;	clrf		CycleCounterH			; 

    goto      	CorrectionMade

GoToTheLeftFast:

    movf      	CurrentValue,w  
    xorlw     	b'00000001'
    btfss     	STATUS,Z     
    goto      	PerpendicularLine1

    btfss		LineState,6		     	; программная блокировка автокоррекции по линии с RS232
    call      	L_FORWARD_R_BACKWARD  	; Разворот на месте по часовой стрелке

    btfss		LineState,4				; если бит наличия линии выставлен
    goto      	CorrectionMade

    bcf			LineState,4				; не теряя возможности снимем его

    clrf		CycleCounterL			; очистим счётчик таймера
    clrf		CycleCounterH			; 

    goto      	CorrectionMade

PerpendicularLine1:						; обнаружили перпендикулярную линию

    movf      	CurrentValue,w  
    xorlw     	b'00001111'
    btfss     	STATUS,Z     
    goto      	PerpendicularLine2

    btfss		LineState,5				; не надо считать время пребывания на старте
    call		CountLines				; обработка найденной линии

    goto      	CorrectionMade

PerpendicularLine2:						; обнаружили перпендикулярную линию

    movf      	CurrentValue,w  
    xorlw     	b'00000111'
    btfss     	STATUS,Z     
    goto      	PerpendicularLine3

    btfss		LineState,5				; не надо считать время пребывания на старте
    call		CountLines

    goto      	CorrectionMade

PerpendicularLine3:						; обнаружили перпендикулярную линию

    movf      	CurrentValue,w  
    xorlw     	b'00001110'
    btfss     	STATUS,Z     
    goto      	CheckError1

    btfss		LineState,5				; не надо считать время пребывания на старте
    call		CountLines

    goto      	CorrectionMade

CheckError1:

    movf      	CurrentValue,w  
    xorlw     	b'00001101'				; вроде как надо вправо
    btfss     	STATUS,Z     
    goto      	CheckError2
    bsf			CurrentValue,1			; приведём к виду 00001111
    goto      	CheckOnceAgain

CheckError2:

    movf      	CurrentValue,w  
    xorlw     	b'00001011'				; вроде как надо вправо
    btfss     	STATUS,Z     
    goto      	CorrectionMade
    bsf			CurrentValue,2			; приведём к виду 00001111
    goto      	CheckOnceAgain

CorrectionMade:

    return

; *******************************************************************
; *		Подсчёт линий разметки - определение номера аудитории
; *******************************************************************
CountLines:
	; будем работать с одной меткой и воспроизводить следующую мелодию 

    btfsc		LineState,4				; если бит наличия линии выставлен, пропустим
    goto		IncrementCounters		
	
    clrf		CycleCounterL			; очистим счётчики
    clrf		CycleCounterH

IncrementCounters: 

    bsf			LineState,4				; выставим бит наличия линии

    btfsc		LineState,6				; ручное управление - не надо воспроизводить
    goto      	EndCountLines

    call		CheckTimer0				; проверка переполения и инкремент

    movf      	CycleCounterL,w   
    xorlw     	b'00010100'				; 20 переполнения таймера
    btfss     	STATUS,Z     
    goto      	EndCountLines 

    call		PlaySong				; воспроизведение мелодии - пока только следующей

EndCountLines:

    return

; *******************************************************************
; *		Проверка переполнения и инкремент
; *******************************************************************
CheckTimer0:

    btfss		INTCON,T0IF   			; ждем переполнения Timer0 
    goto		EndCheckTimer0
    bcf			INTCON,T0IF    			; программный сброс флага переполнения
    incf		CycleCounterL,f 		; увеличим число циклов счётика на 1
    btfsc		STATUS,Z   				; увеличим старшую часть если младшая переполнилась до 128
    incf		CycleCounterH,f 		; увеличим число циклов счётика на 1

EndCheckTimer0:
    return


; *******************************************************************
; *		Воспроизведение мелодии по её номеру - различные задержки для разных мелодий
; *		+ подпрограмки нажатия кнопок плеера
; *******************************************************************
PlaySong:

;	btfss		LineState,6				; программная блокировка автокоррекции по линии с RS232
;    call      	L_FORWARD_R_FORWARD   	; Движение вперёд

;	call		Delay_1_sec				; съедем с линии немного
 
    call      	L_STOP_R_STOP 			; остановка

    call		TurnScreenOn			; сначала включим экран
    call		PlayPauseCurrentSong	; воспроизведение очередной мелодии

	;=====	начальные установки
    bsf       	STATUS,RP0				; Выбор Register Bank 1
    movlw		b'00000111'     		; сконфигурируем Timer0.
    movwf		OPTION_REG      		; прескейлер 1:256
    bcf       	STATUS,RP0				; Выбор Register Bank 1

    clrf		CycleCounterL			; очистим счётчик таймера
    clrf		CycleCounterH			; 

Room1Delay:

    movf      	CurrentSongNumber,w    
    xorlw     	b'00000000'
    btfss     	STATUS,Z     
    goto      	Room2Delay
 
    call		CheckTimer0

    movf      	CycleCounterH,w   
    xorlw     	b'00000001'				; 18 секунд
    btfss     	STATUS,Z     
    goto		$-4						; вернёмся на проверку таймера    
    goto      	SetNextRoomNumber 

Room2Delay:
    movf      	CurrentSongNumber,w    
    xorlw     	b'00000001'
    btfss     	STATUS,Z     
    goto      	Room3Delay

    call		CheckTimer0

    movf      	CycleCounterH,w   
    xorlw     	b'00000001'				; 18 секунд
    btfss     	STATUS,Z     
    goto		$-4						; вернёмся на проверку таймера    
    goto      	SetNextRoomNumber 

Room3Delay:
    movf      	CurrentSongNumber,w    
    xorlw     	b'00000010'
    btfss     	STATUS,Z     
    goto      	Room4Delay

    call		CheckTimer0

    movf      	CycleCounterH,w   
    xorlw     	b'00000001'				; 18 секунд
    btfss     	STATUS,Z     
    goto		$-4						; вернёмся на проверку таймера    

	
    call		L_STOP_R_STOP			; остановимся в конце обхода

    bsf			LineState,6				; программная блокировка автокоррекции по линии с RS232

    goto      	SetNextRoomNumber 

Room4Delay:
    movf      	CurrentSongNumber,w    
    xorlw     	b'00000011'
    btfss     	STATUS,Z     
    goto      	Room5Delay

    call		CheckTimer0

    movf      	CycleCounterH,w   
    xorlw     	b'00000001'				; 18 секунд
    btfss     	STATUS,Z     
    goto		$-4						; вернёмся на проверку таймера   
    goto      	SetNextRoomNumber 

Room5Delay:
    movf      	CurrentSongNumber,w    
    xorlw     	b'00000100'
    btfss     	STATUS,Z     
    goto      	Room6Delay

    call		CheckTimer0

    movf      	CycleCounterH,w   
    xorlw     	b'00000001'				; 18 секунд
    btfss     	STATUS,Z     
    goto		$-4						; вернёмся на проверку таймера    
    goto      	SetNextRoomNumber 

Room6Delay:
    movf      	CurrentSongNumber,w    
    xorlw     	b'00000101'
    btfss     	STATUS,Z     
    goto      	Room7Delay

    call		CheckTimer0

    movf      	CycleCounterH,w   
    xorlw     	b'00000001'				; 18 секунд
    btfss     	STATUS,Z     
    goto		$-4						; вернёмся на проверку таймера    
    goto      	SetNextRoomNumber 

Room7Delay:
    movf      	CurrentSongNumber,w    
    xorlw     	b'00000110'
    btfss     	STATUS,Z     
    goto      	Room8Delay

    call		CheckTimer0

    movf      	CycleCounterH,w   
    xorlw     	b'00000001'				; 18 секунд
    btfss     	STATUS,Z     
    goto		$-4						; вернёмся на проверку таймера    
    goto      	SetNextRoomNumber 

Room8Delay:
    movf      	CurrentSongNumber,w    
    xorlw     	b'00000111'
    btfss     	STATUS,Z     
    goto      	Room9Delay

    call		CheckTimer0

    movf      	CycleCounterH,w   
    xorlw     	b'00000001'				; 18 секунд
    btfss     	STATUS,Z     
    goto		$-4						; вернёмся на проверку таймера    
    goto      	SetNextRoomNumber 

Room9Delay:
    movf      	CurrentSongNumber,w    
    xorlw     	b'00001000'
    btfss     	STATUS,Z     
    goto      	SetNextRoomNumber

    call		CheckTimer0

    movf      	CycleCounterH,w   
    xorlw     	b'00000001'				; 18 секунд
    btfss     	STATUS,Z     
    goto		$-4						; вернёмся на проверку таймера    
	
    call		L_STOP_R_STOP			; остановимся в конце обхода

    bsf			LineState,6				; программная блокировка автокоррекции по линии с RS232
	
    goto      	SetNextRoomNumber 

SetNextRoomNumber:

    call		TurnScreenOn			; сначала включим экран
    call		PlayPauseCurrentSong	; пауза
    call		NextSong				; перейдём на след песенку

    incf		CurrentSongNumber		; следующая комната

	; вернём параметры таймера для "шараханья" от стен и определения линии
    bsf       	STATUS,RP0				; Выбор Register Bank 1
    movlw		b'00000100'     		; сконфигурируем Timer0.
    movwf		OPTION_REG      		; прескейлер 1:32
    bcf       	STATUS,RP0				; Выбор Register Bank 1

    clrf		CycleCounterL			; очистим счётчик таймера
    clrf		CycleCounterH			; 

    bcf			LineState,4				; снимем бит наличия линии

    btfss		LineState,6				; программная блокировка автокоррекции по линии с RS232
    call      	L_FORWARD_R_FORWARD   	; Движение вперёд

    call		Delay_6_sec				; проедем немного прямо вперёд - дверь нам определять не к чему

    return

;============= управление плеером ==============
;	bsf			PORTE,0   			; М 
;	bcf			PORTE,0
;	bsf			PORTE,1   			; Play/Pause
;	bcf			PORTE,1
;	bsf			PORTE,2   			; Next
;	bcf			PORTE,2
;	bsf			PORTA,4   			; Prev
;	bcf			PORTA,4

PlayPauseCurrentSong:					; воспроизвести текущую
    call		Delay_197_ms		; небольшая задержка
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

PrevSong:							; перейти на одну назад
    call		Delay_197_ms		; небольшая задержка
    call		Delay_197_ms		
    call		Delay_197_ms
	;call		Delay_197_ms

    bsf			PORTA,4   			; Prev
    call		Delay_197_ms
    call		Delay_197_ms
    bcf			PORTE,4

    return

NextSong:							; перейти на одну вперёд
    call		Delay_197_ms		; небольшая задержка
    call		Delay_197_ms
    call		Delay_197_ms
	;call		Delay_197_ms		; так он листает через одну

    bsf			PORTE,2   			; Next
    call		Delay_197_ms
    call		Delay_197_ms
    bcf			PORTE,2
	
    return

TurnScreenOn:
	
    bsf			PORTE,1   			; разбудим плеер
    call		Delay_197_ms
    call		Delay_197_ms
    call		Delay_197_ms
    call		Delay_197_ms
    bcf			PORTE,1
 
    return


;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;||		Работа с АЦП
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

; *******************************************************************
; *		запуск нового АЦ преобразования !для 4мГц
; *******************************************************************

StartADC:						
    nop							; wait 5uS for A2D amp to settle and capacitor to charge.
    nop							; wait 4uS
    nop							; wait 3uS
    nop							; wait 2uS 
    nop							; wait 1uS

    bsf       	ADCON0,GO_DONE	; начали преобразование

    return 

; *******************************************************************
; *		проверка поверхности на наличие линии - подпрограмма работы АЦП
; *******************************************************************
SurfaseCheck:

	; для начала определим которое больше - новое или базовое
    subwf		CurrentValue,w	; вычтем из пред значения текущее и оставим его в аккумуляторе
    btfss		STATUS,C		; проверим бит переполнения - С=0 новое значение > старого, С=1 <= старому
    goto		VoltageUp
    goto		VoltageDown

VoltageUp:						; напруга поднялась относительно поверхности
								; вычли из меньшего большее - результат в обратном код
    sublw		b'11111111'		; дополним до нормального представления числа из допкода
    addlw		b'00000001'		; единичку в младшем разряде нельзя терять

VoltageDown:					; напруга упала относительно поверхности
								; вычли из большего меньшее - результат в прямом коде

    subwf		VoltageTreshhold,w; вычтем из значения порога напряжения разность пред. и текущего напряжений

    clrf		CurrentValue	; более не нужен, внесём возвращаемое значение

    btfsc		STATUS,C		; проверим бит переполнения - С=0 WReg > литеры, С=1 <= литеры
    goto		GotLine 		; <= Порога - снова нашли линию
    goto		NoLine 			; разность > Порога	- нет линиb

NoLine:	
    bcf			CurrentValue,0	; снимем бит обнаружения линии
	
    goto		EndSurfaseCheck	;  

GotLine:	
    bsf			CurrentValue,0	; выставим бит обнаружения линии

EndSurfaseCheck:

    return

;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;||								RS232
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

; *******************************************************************
; *		Приём данных через RS232
; *******************************************************************
ReceiveBit:
    btfss	PIR1,RCIF		; если бит сброшен в 0, то что-то было принято
    goto 	NothingReceived
    movf	RCREG,w			; 

    movwf	RS232Received

NothingReceived:

    btfsc	RCSTA,OERR		; ошибка переполнения буфера
    bcf		RCSTA,OERR

    return


; *******************************************************************
; *		Отправка данных через RS232
; *******************************************************************
SendBit:
    bsf		STATUS,RP0		; проверка окончания передачи
StillNotSent:					; сначала проверим, передали ли предыдущий байт
    btfss	TXSTA,TRMT		; если бит выставлен, то передача завершена
    goto	StillNotSent
    bcf		STATUS,RP0

    movwf	TXREG			; теперь передадим новый байт

    return


; *******************************************************************
; *		Обработка принятого по RS232 управляющего символа
; *******************************************************************
MasterToldMe:
	
    movf      	RS232Received,w           
    xorlw     	b'00000000'				; нулевой - ничего не надо делать!
    btfss     	STATUS,Z     
    goto      	VladDataExchangeStart
    goto      	OrderExecuted 

VladDataExchangeStart:
    movf      	RS232Received,w           
    xorlw     	b'11111111'				; инициализация приёма
    btfss     	STATUS,Z     
    goto      	IfRS232Forward

    call		VladDataExchange		; обработка принятых данных

    clrf		RS232Received			; чтобы не было циклических повторов выполнения одной и той же команды

    goto      	OrderExecuted 

IfRS232Forward:
    movf      	RS232Received,w           
    xorlw     	'8'
    btfss     	STATUS,Z     
    goto      	IfRS232Backward

    call      	L_FORWARD_R_FORWARD   	; Движение вперёд

    clrf		RS232Received			; чтобы не было циклических повторов выполнения одной и той же команды

    goto      	OrderExecuted  
  
IfRS232Backward:
    movf      	RS232Received,w           
    xorlw     	'2'
    btfss     	STATUS,Z     
    goto      	IfRS232ForwardAndLeft

    call      	L_BACKWARD_R_BACKWARD 	; Движение назад

    clrf		RS232Received			; чтобы не было циклических повторов выполнения одной и той же команды

    goto      	OrderExecuted

IfRS232ForwardAndLeft:
    movf      	RS232Received,w           
    xorlw     	'7' 
    btfss     	STATUS,Z     
    goto      	IfRS232ForwardAndRight

    call      	L_STOP_R_FORWARD 		; Поворот вперёд влево
    call		Delay_197_ms
    call      	L_STOP_R_STOP 			; Остановка

    clrf		RS232Received			; чтобы не было циклических повторов выполнения одной и той же команды

    goto      	OrderExecuted
    
IfRS232ForwardAndRight:
    movf      	RS232Received,w           
    xorlw     	'9'
    btfss     	STATUS,Z     
    goto      	IfRS232BackwardAndLeft

    call      	L_FORWARD_R_STOP 		; Поворот вперёд вправо
    call		Delay_197_ms
    call      	L_STOP_R_STOP 			; Остановка

    clrf		RS232Received			; чтобы не было циклических повторов выполнения одной и той же команды

    goto      	OrderExecuted

IfRS232BackwardAndLeft:
    movf      	RS232Received,w           
    xorlw     	'1'
    btfss     	STATUS,Z     
    goto      	IfRS232BackwardAndRight

    call      	L_STOP_R_BACKWARD 		; Поворот назад влево
    call		Delay_197_ms
    call      	L_STOP_R_STOP 			; Остановка

    clrf		RS232Received			; чтобы не было циклических повторов выполнения одной и той же команды

    goto      	OrderExecuted

IfRS232BackwardAndRight:
    movf      	RS232Received,w           
    xorlw     	'3'
    btfss     	STATUS,Z     
    goto      	IfRS232TurnConterClockwise

    call      	L_BACKWARD_R_STOP 		; Поворот назад вправо
    call		Delay_197_ms
    call      	L_STOP_R_STOP 			; Остановка

    clrf		RS232Received			; чтобы не было циклических повторов выполнения одной и той же команды

    goto      	OrderExecuted

IfRS232TurnConterClockwise:
    movf      	RS232Received,w           
    xorlw    	'6'
    btfss     	STATUS,Z     
    goto      	IfRS232TurnClockwise

    call      	L_BACKWARD_R_FORWARD  	; Разворот на месте против часовой стрелки
    call		Delay_197_ms
    call      	L_STOP_R_STOP 			; Остановка

    clrf		RS232Received			; чтобы не было циклических повторов выполнения одной и той же команды

    goto      	OrderExecuted

IfRS232TurnClockwise:
    movf      	RS232Received,w           
    xorlw     	'4'
    btfss     	STATUS,Z     
    goto      	IfRS232Stop

    call      	L_FORWARD_R_BACKWARD  	; Разворот на месте по часовой стрелке
    call		Delay_197_ms
    call      	L_STOP_R_STOP 			; Остановка

    clrf		RS232Received			; чтобы не было циклических повторов выполнения одной и той же команды

    goto      	OrderExecuted    

IfRS232Stop:
    movf      	RS232Received,w           
    xorlw     	'5'
    btfss     	STATUS,Z   
    goto      	IfRS232ManualOperation	; прошли сверху вниз. полученный символ не является командой

    call      	L_STOP_R_STOP 			; Остановка

    clrf		RS232Received			; чтобы не было циклических повторов выполнения одной и той же команды

    goto      	OrderExecuted


IfRS232ManualOperation:					; ручное управление по RS232
    movf      	RS232Received,w           
    xorlw     	'm'
    btfss     	STATUS,Z     
    goto      	IfRS232AutomaticOperation

    bsf			LineState,6				;

    clrf		RS232Received			; чтобы не было циклических повторов выполнения одной и той же команды

    goto      	OrderExecuted 

IfRS232AutomaticOperation:				; автоматическая работа тележки
    movf      	RS232Received,w           
    xorlw     	'a'
    btfss     	STATUS,Z     
    goto      	IfRS232PlayPauseSong

    bcf			LineState,6				;

    clrf		RS232Received			; чтобы не было циклических повторов выполнения одной и той же команды

    goto      	OrderExecuted 

IfRS232PlayPauseSong:					; Воспроизведение следующей мелодии
    movf      	RS232Received,w           
    xorlw     	'p'
    btfss     	STATUS,Z     
    goto      	IfRS232SendSensorData

    call		PlaySong
	
    clrf		RS232Received			; чтобы не было циклических повторов выполнения одной и той же команды

    goto      	OrderExecuted 

IfRS232SendSensorData:					; Слова состояния сенсоров отсылаем оператору
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

; оставить
;    movlw		b'10000001' 
;    call		SendBit 

    movf		LineState,w
    call		SendBit 

    movf		Barriers,w
    call		SendBit 

;    movlw		b'10000001' 
;    call		SendBit 


    clrf		RS232Received			; чтобы не было циклических повторов выполнения одной и той же команды

    goto      	OrderExecuted 

OrderExecuted:	; символ успешно обработан

    return


; *******************************************************************
; *		Протокол обмена с прогой Влада
; *******************************************************************
VladDataExchange:

;		MessageStart			; b'11111111'- всегда одно и то же, инициализация
;		MessageParams			; b'11xxxxxx'- <7:6> - всегда b'11', <5:2> - длина сообщения, <1:0> - контроль
;		Byte0					; протокол обмена с прогой Влада 
;		Byte1					; максимум 16 байт данных за раз
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
;		MessageEnd				; '#' - всегда одно и то же, конец передачи
;		MessageLength			; длина сообщения для установки из подпрограмм

	
    movlw		RS232Received	; не обязательно, так как обрабатываем сразу после получения

    call		ReceiveBit		; примем байт

    movlw		RS232Received	; не обязательно, так как обрабатываем сразу после получения

    movwf		MessageParams	; параметры принимаемой команды

;	movwf		MessageLength	; длина принимаемой команды

;	rrf			MessageLength,f	; сдвинем вправо на 2 бита
;	rrf			MessageLength,f

    movlw		b'00001111'		; выделим длину сообщения
    andwf		MessageLength,f

    movlw		0x36			; адрес Byte0
    movwf		FSR				; косвенная адресация

    clrf		MessageLength

	; добавить таймер


ReceiveMessage:					; примем само сообщение
	
    call		ReceiveBit		; примем байт 

    incf		MessageLength	; счётчик принятых байтов

    xorlw     	b'10001'		; 18 байт явно лишний (17й - терминатор)
    btfsc     	STATUS,Z     
    goto      	EndVladDataExchange	; если приянто больше 16 байтов, прервём приём

    movf		RS232Received,w	; 

    movwf		INDF			; запомним полученный байт в отдельном регистре
    incf		FSR 			; увеличим адрес

	; проверять, был ли приём и приделать таймер - прекращение приёма при долгом молчании

	; воткнуть ограничение на 16 символов - больше 16 - отправка ошибки!

    xorlw     	'#'				; приняли символ конца сообщения?
    btfss     	STATUS,Z     	
    goto		ReceiveMessage	; нет, продолжим приём	

    decf		MessageLength	; последним был принят стоповый, он нам не интересен

    movlw		0x36			; адрес Byte0
    movwf		FSR				; косвенная адресация

    clrf		RS232Received	; чтобы не было повторного вызова чего-либо

ProcessWhatYouReceived:

SS:
    movf      	INDF,w        			; Byte0
    xorlw     	'S'
    btfss     	STATUS,Z     
    goto      	FF

    incf		FSR 					; увеличим адрес

    movf      	INDF,w        			; Byte1
    xorlw     	'S'
    btfss     	STATUS,Z     
    goto      	EndVladDataExchange		; нет такой команды

    call      	L_STOP_R_STOP 			; Остановка

    goto      	EndVladDataExchange 
	
; ====== маневры при движении вперёд
FF:
    movf      	INDF,w        			; Byte0
    xorlw     	'F'
    btfss     	STATUS,Z     
    goto      	BB

    incf		FSR 					; увеличим адрес

    movf      	INDF,w        			; Byte1
    xorlw     	'F'
    btfss     	STATUS,Z     
    goto      	FR						; 

	; двигаться вперёд

    call      	L_FORWARD_R_FORWARD   	; Движение вперёд

    goto      	EndVladDataExchange 

FR:
    movf      	INDF,w        			; Byte1
    xorlw     	'R'
    btfss     	STATUS,Z     
    goto      	FL						; 

	; повернуть вперёд и направо на мин. угол

    call      	L_FORWARD_R_STOP 		; Поворот вперёд вправо
    call		Delay_197_ms
    call      	L_STOP_R_STOP 			; Остановка

    goto      	EndVladDataExchange 

FL:
    movf      	INDF,w        			; Byte1
    xorlw     	'L'
    btfss     	STATUS,Z     
    goto      	FR90					; 

	;  повернуть вперёд и налево на мин. угол

    call      	L_STOP_R_FORWARD 		; Поворот вперёд влево
    call		Delay_197_ms
    call      	L_STOP_R_STOP 			; Остановка

    goto      	EndVladDataExchange 

FR90:
    movf      	INDF,w        			; Byte1
    xorlw     	'+'
    btfss     	STATUS,Z     
    goto      	FL90					; 

	; повернуть вперёд и направо на 90 градусов

    call      	L_FORWARD_R_STOP 		; Поворот вперёд вправо

    call		Delay_1_sec
    call		Delay_1_sec

    call		Delay_197_ms
    call		Delay_197_ms

    call      	L_STOP_R_STOP 			; Остановка

    goto      	EndVladDataExchange 

FL90:
    movf      	INDF,w        			; Byte1
    xorlw     	'-'
    btfss     	STATUS,Z     
    goto      	ErrorFound				; нет такой команды

	; повернуть вперёд и налево на 90 градусов

    call      	L_STOP_R_FORWARD 		; Поворот вперёд влево

    call		Delay_1_sec
    call		Delay_1_sec

    call		Delay_197_ms
    call		Delay_197_ms

    call      	L_STOP_R_STOP 			; Остановка

    goto      	EndVladDataExchange 


; ====== маневры при движении назад
BB:
    movf      	INDF,w        			; последовательно проанализируем полученные байты   
    xorlw     	'B'
    btfss     	STATUS,Z     
    goto      	TankStyleRight

    incf		FSR 					; увеличим адрес

    movf      	INDF,w        			; Byte1
    xorlw     	'B'
    btfss     	STATUS,Z     
    goto      	BR				; 

	; строго назад

    call      	L_BACKWARD_R_BACKWARD 	; Движение назад

    goto      	EndVladDataExchange 

BR:
    movf      	INDF,w        			; Byte1
    xorlw     	'R'
    btfss     	STATUS,Z     
    goto      	BL						; 

	; повернуть назад и направо на мин. угол

    call      	L_BACKWARD_R_STOP 		; Поворот назад вправо
    call		Delay_197_ms
    call      	L_STOP_R_STOP 			; Остановка

    goto      	EndVladDataExchange 

BL:
    movf      	INDF,w        			; Byte1
    xorlw     	'L'
    btfss     	STATUS,Z     
    goto      	BR90					; 

	; повернуть назад и налево на мин. угол

    call      	L_STOP_R_BACKWARD 		; Поворот назад влево
    call		Delay_197_ms
    call      	L_STOP_R_STOP 			; Остановка

    goto      	EndVladDataExchange 

BR90:
    movf      	INDF,w        			; Byte1
    xorlw     	'+'
    btfss     	STATUS,Z     
    goto      	BL90				; 

	; повернуть назад и направо на 90 градусов

    call      	L_BACKWARD_R_STOP 		; Поворот назад вправо

    call		Delay_1_sec
    call		Delay_1_sec

    call		Delay_197_ms
    call		Delay_197_ms

    call      	L_STOP_R_STOP 			; Остановка

    goto      	EndVladDataExchange 

BL90:
    movf      	INDF,w        			; Byte1
    xorlw     	'-'
    btfss     	STATUS,Z     
    goto      	ErrorFound				; нет такой команды

	; повернуть назад и налево на 90 градусов

    call      	L_STOP_R_BACKWARD 		; Поворот назад влево

    call		Delay_1_sec
    call		Delay_1_sec

    call		Delay_197_ms
    call		Delay_197_ms

    call      	L_STOP_R_STOP 			; Остановка

    goto      	EndVladDataExchange 

; ====== танковые манёвры
TankStyleRight:
    movf      	INDF,w        			; Byte0
    xorlw     	'R'						; танковые манёвры вправо
    btfss     	STATUS,Z     
    goto      	TankStyleLeft

    incf		FSR 					; увеличим адрес

    movf      	INDF,w        			; Byte1
    xorlw     	'T'
    btfss     	STATUS,Z     
    goto      	R9				; 

	; повернуть направо на мин. угол, используя танковы разворот

    call      	L_FORWARD_R_BACKWARD  	; Разворот на месте по часовой стрелке
    call		Delay_197_ms
    call      	L_STOP_R_STOP 			; Остановка

    goto      	EndVladDataExchange 

R9:
    movf      	INDF,w        			; Byte1
    xorlw     	'9'
    btfss     	STATUS,Z     
    goto      	RR				; 

	; повернуть направо на 90 градусов, используя танковы разворот

    call      	L_FORWARD_R_BACKWARD  	; Разворот на месте по часовой стрелке

    call		Delay_1_sec
    call		Delay_1_sec

    call		Delay_197_ms
    call		Delay_197_ms

    call      	L_STOP_R_STOP 			; Остановка

    goto      	EndVladDataExchange 

RR:
    movf      	INDF,w        			; Byte1
    xorlw     	'R'
    btfss     	STATUS,Z     
    goto      	ErrorFound				; нет такой команды

	; повернуть направо на 180 градусов, используя танковы разворот

    call      	L_FORWARD_R_BACKWARD  	; Разворот на месте по часовой стрелке

    call		Delay_1_sec
    call		Delay_1_sec

    call		Delay_197_ms
    call		Delay_197_ms

    call		Delay_1_sec
    call		Delay_1_sec

    call		Delay_197_ms
    call		Delay_197_ms

    call      	L_STOP_R_STOP 			; Остановка

    goto      	EndVladDataExchange 

TankStyleLeft
    movf      	INDF,w        			; Byte0
    xorlw     	'L'						; танковые манёвры вправо
    btfss     	STATUS,Z     
    goto      	GetData

    incf		FSR 					; увеличим адрес

    movf      	INDF,w        			; Byte1
    xorlw     	'T'
    btfss     	STATUS,Z     
    goto      	L9				; 

	; повернуть налево на мин. угол, используя танковы разворот

    call      	L_BACKWARD_R_FORWARD  	; Разворот на месте против часовой стрелки
    call		Delay_197_ms
    call      	L_STOP_R_STOP 			; Остановка

    goto      	EndVladDataExchange 

L9:
    movf      	INDF,w        			; Byte1
    xorlw     	'9'
    btfss     	STATUS,Z     
    goto      	LL				; 

	; повернуть налево на 90 градусов, используя танковы разворот

    call      	L_BACKWARD_R_FORWARD  	; Разворот на месте против часовой стрелки

    call		Delay_1_sec
    call		Delay_1_sec

    call		Delay_197_ms
    call		Delay_197_ms

    call      	L_STOP_R_STOP 			; Остановка

    goto      	EndVladDataExchange 

LL:
    movf      	INDF,w        			; Byte1
    xorlw     	'L'
    btfss     	STATUS,Z     
    goto      	ErrorFound				; нет такой команды

	; повернуть налево на 180 градусов, используя танковы разворот

    call      	L_BACKWARD_R_FORWARD  	; Разворот на месте против часовой стрелки

    call		Delay_1_sec
    call		Delay_1_sec

    call		Delay_197_ms
    call		Delay_197_ms

    call		Delay_1_sec
    call		Delay_1_sec

    call		Delay_197_ms
    call		Delay_197_ms

    call      	L_STOP_R_STOP 			; Остановка

    goto      	EndVladDataExchange 


GetData:
    movf      	INDF,w        			; Byte0
    xorlw     	'G'
    btfss     	STATUS,Z     
    goto      	ErrorFound				; нет такой команды

    incf		FSR 					; увеличим адрес

    movf      	INDF,w        			; Byte1
    xorlw     	'D'
    btfss     	STATUS,Z     
    goto      	ErrorFound				; нет такой команды

	; передача данных о текущем состоянии датчиков

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

ErrorFound:								; ничего похожего на допустимую команду не найдено


EndVladDataExchange:
	
    return


; *******************************************************************
; *		Сообщение инициализации 
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
; *		передать конец строки
; *******************************************************************
EndLine:
    movlw  0x0D ; CR 
    call SendBit 
    movlw  0x0A ; LF 
    call SendBit 
		
    return       


;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;||		Подпрограммы управления двигателями
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

; *******************************************************************
; *		изменение направления врещения гусенииц
; *******************************************************************

L_STOP_R_STOP: ; Остановка

    bcf			SpaceOptions,0			; не едем назад!

    bsf			PORTD,0      			; оба управляющих сигнала выставим в "1" 				
    bsf			PORTD,1					; при ненулевой скважности для быстрой остановки
    bsf			PORTD,2				
    bsf			PORTD,3						
	
    clrf		CCPR2L					; скважность лев. канала  = 0%	
    clrf		CCPR1L					; скважность пр. канала = 0%	
	
    return

L_FORWARD_R_FORWARD: ; Движение вперёд

    bcf			SpaceOptions,0			; не едем назад!

    call		L_HiSpeed
    call		R_HiSpeed

    bsf			PORTD,0      			; прав. 	
    bcf			PORTD,1			
    bsf			PORTD,2					; лев.
    bcf			PORTD,3						

    return

L_BACKWARD_R_BACKWARD: ; Движение назад

    bsf			SpaceOptions,0			; тут уже едем назад!

    call		L_HiSpeed
    call		R_HiSpeed

    bcf			PORTD,0      			; прав.	
    bsf			PORTD,1						
    bcf			PORTD,2					; лев.
    bsf			PORTD,3						

    return

L_STOP_R_FORWARD: ; Поворот вперёд влево 

    call		R_HiSpeed

    bcf			SpaceOptions,0			; не едем назад!

    bsf			PORTD,0      			; прав.	
    bsf			PORTD,1					
    bsf			PORTD,2				
    bcf			PORTD,3					; лев.	

    return

L_FORWARD_R_STOP: ; Поворот вперёд вправо

    call		L_HiSpeed

    bcf			SpaceOptions,0			; не едем назад!

    bsf			PORTD,0      			; прав.	
    bcf			PORTD,1				
    bsf			PORTD,2					; лев.
    bsf			PORTD,3						

    return

L_STOP_R_BACKWARD: ; Поворот назад влево
	
    call		R_HiSpeed

    bcf			SpaceOptions,0			; не едем назад!

    bsf			PORTD,0      			; прав.	
    bsf			PORTD,1	
    bcf			PORTD,2					; лев.
    bsf			PORTD,3

    return

L_BACKWARD_R_STOP: ; Поворот назад вправо
	
    call		L_HiSpeed

    bcf			SpaceOptions,0			; не едем назад!

    bcf			PORTD,0      			; прав.	
    bsf			PORTD,1
    bsf			PORTD,2					; лев.
    bsf			PORTD,3

    return

L_BACKWARD_R_FORWARD: ; Разворот на месте против часовой стрелки
	
    call		L_HiSpeed
    call		R_HiSpeed

    bcf			SpaceOptions,0			; не едем назад!

    bcf			PORTD,0      			; прав.	
    bsf			PORTD,1			
    bsf			PORTD,2					; лев.
    bcf			PORTD,3

    return

L_FORWARD_R_BACKWARD: ; Разворот на месте по часовой стрелке
	
    call		L_HiSpeed
    call		R_HiSpeed

    bcf			SpaceOptions,0			; не едем назад!

    bsf			PORTD,0      			; прав.		
    bcf			PORTD,1	
    bcf			PORTD,2					; лев.
    bsf			PORTD,3

    return

; *******************************************************************
; *		обслуживание цикла ШИМ - изменение скважности
; *******************************************************************
CheckPWMTimer:

    btfsc		PIR1,TMR2IF		; программно очищаем бит переполнения таймера ШИМ
    bcf			PIR1,TMR2IF

    return

; *******************************************************************
; *		Изменение скважности ШИМ = ускорение или замедление
; *******************************************************************

; норма / правый
R_HiSpeed:

    movlw		b'10000000'		; норма скважности - 50%
    movwf		CCPR1L			; вносим новое значение скважности

    return

; норма / левый
L_HiSpeed:

    movlw		b'10000000'		; норма скважности - 50%
    movwf		CCPR2L			; вносим новое значение скважности

    return

; ===== с текущими движками работает плохо - не хватает мощности, посему не используется
; медленнее / правый
R_LowSpeed:
		
    movlw		b'01100110'		; скважность 40%
    movwf		CCPR1L			; вносим новое значение скважности

    return

; медленнее / левый
L_LowSpeed:

    movlw		b'01100110'		; скважность 40%
    movwf		CCPR2L			; вносим новое значение скважности

    return


;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;||					Программные задержки
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

; *******************************************************************
; *		Задержка 1 секунда
; *******************************************************************
Delay_1_sec:
	

    clrf 	   Delay1
    clrf 	   Delay2

;	 movlw     0x32            ; для 10 сек
;	 movlw     0x1E            ; для 6 сек
    movlw     0x5             ; для 1 сек

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
; *		Задержка 6 секунд
; *******************************************************************
Delay_6_sec:
	
	; 0x32 - последний цикл

    clrf 	   Delay1
    clrf 	   Delay2

;	 movlw     0x32            ; для 10 сек
    movlw     0x1E            ; для 6 сек

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
; *		Задержка 197 милисекунд
; *******************************************************************
Delay_197_ms:
    decfsz    Delay1,f            ; Waste time.  
    goto      Delay_197_ms        	; The Inner loop takes 3 instructions per loop * 256 loops = 768 instructions
    decfsz    Delay2,f            ; The outer loop takes and additional 3 instructions per lap * 256 loops
    goto      Delay_197_ms        	; (768+3) * 256 = 197376 instructions / 1M instructions per second = 0.197 sec.
                                   ; call it two-tenths of a second.
    return 

; *******************************************************************
; *		Задержка 1 милисекунда
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
; *		Задержка 5 милисекунд
; *******************************************************************
Delay_5_ms:

    movlw     0x5             	  ; 
    movwf     Delay1
    call	   Delay_1_ms
    decfsz    Delay1,f          
    goto      $-2       
                                   
    return

; *******************************************************************
; *		Издать короткий писк - 2 мс
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
;========================Конец программы прошивки=======================
; **********************************************************************