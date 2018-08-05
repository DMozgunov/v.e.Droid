EESchema Schematic File Version 2
LIBS:Player-rescue
LIBS:power
LIBS:device
LIBS:switches
LIBS:relays
LIBS:motors
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:Player-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date "23 jan 2010"
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Wire Wire Line
	6150 5250 6350 5250
Wire Wire Line
	6150 4400 6350 4400
Wire Wire Line
	6350 3550 6150 3550
Wire Wire Line
	6350 3350 6150 3350
Wire Wire Line
	6350 2500 6150 2500
Connection ~ 4100 3850
Wire Wire Line
	3950 3850 4100 3850
Connection ~ 4100 3500
Wire Wire Line
	5050 2650 4100 2650
Wire Wire Line
	4100 2650 4100 5200
Wire Wire Line
	5050 3500 4100 3500
Wire Wire Line
	3950 3750 4200 3750
Wire Wire Line
	3950 3650 4350 3650
Wire Wire Line
	3950 3450 4000 3450
Wire Wire Line
	4000 3450 4000 2300
Wire Wire Line
	4000 2300 4400 2300
Wire Wire Line
	4350 3150 4350 3550
Wire Wire Line
	4350 3150 4400 3150
Wire Wire Line
	4900 4850 5050 4850
Wire Wire Line
	4900 2300 5050 2300
Wire Wire Line
	5050 3150 4900 3150
Wire Wire Line
	4900 4000 5050 4000
Wire Wire Line
	4400 4000 4350 4000
Wire Wire Line
	4350 4000 4350 3650
Wire Wire Line
	4350 3550 3950 3550
Wire Wire Line
	4100 5200 5050 5200
Wire Wire Line
	5050 4350 4100 4350
Connection ~ 4100 4350
Wire Wire Line
	4200 3750 4200 4850
Wire Wire Line
	4200 4850 4400 4850
Wire Wire Line
	6350 2700 6150 2700
Wire Wire Line
	6350 4200 6150 4200
Wire Wire Line
	6350 5050 6150 5050
$Comp
L CONN_2 P?
U 1 1 4B5B3942
P 6700 5150
AR Path="/4B5B3937" Ref="P?"  Part="1" 
AR Path="/4B5B3942" Ref="P5"  Part="1" 
F 0 "P5" V 6650 5150 40  0000 C CNN
F 1 "4" V 6750 5150 40  0000 C CNN
F 2 "" H 6700 5150 60  0001 C CNN
F 3 "" H 6700 5150 60  0001 C CNN
	1    6700 5150
	1    0    0    -1  
$EndComp
$Comp
L CONN_2 P?
U 1 1 4B5B393E
P 6700 4300
AR Path="/4B5B3937" Ref="P?"  Part="1" 
AR Path="/4B5B393E" Ref="P4"  Part="1" 
F 0 "P4" V 6650 4300 40  0000 C CNN
F 1 "3" V 6750 4300 40  0000 C CNN
F 2 "" H 6700 4300 60  0001 C CNN
F 3 "" H 6700 4300 60  0001 C CNN
	1    6700 4300
	1    0    0    -1  
$EndComp
$Comp
L CONN_2 P?
U 1 1 4B5B393B
P 6700 3450
AR Path="/4B5B3937" Ref="P?"  Part="1" 
AR Path="/4B5B393B" Ref="P3"  Part="1" 
F 0 "P3" V 6650 3450 40  0000 C CNN
F 1 "2" V 6750 3450 40  0000 C CNN
F 2 "" H 6700 3450 60  0001 C CNN
F 3 "" H 6700 3450 60  0001 C CNN
	1    6700 3450
	1    0    0    -1  
$EndComp
$Comp
L CONN_2 P2
U 1 1 4B5B3937
P 6700 2600
F 0 "P2" V 6650 2600 40  0000 C CNN
F 1 "1" V 6750 2600 40  0000 C CNN
F 2 "" H 6700 2600 60  0001 C CNN
F 3 "" H 6700 2600 60  0001 C CNN
	1    6700 2600
	1    0    0    -1  
$EndComp
$Comp
L CONN_5 P1
U 1 1 4B5B383A
P 3550 3650
F 0 "P1" V 3500 3650 50  0000 C CNN
F 1 "Player Control" V 3700 3650 50  0000 C CNN
F 2 "" H 3550 3650 60  0001 C CNN
F 3 "" H 3550 3650 60  0001 C CNN
	1    3550 3650
	-1   0    0    1   
$EndComp
$Comp
L R-RESCUE-Player R4
U 1 1 4B5B380C
P 4650 4850
F 0 "R4" V 4730 4850 50  0000 C CNN
F 1 "200" V 4650 4850 50  0000 C CNN
F 2 "" H 4650 4850 60  0001 C CNN
F 3 "" H 4650 4850 60  0001 C CNN
	1    4650 4850
	0    1    1    0   
$EndComp
$Comp
L R-RESCUE-Player R3
U 1 1 4B5B380B
P 4650 4000
F 0 "R3" V 4730 4000 50  0000 C CNN
F 1 "200" V 4650 4000 50  0000 C CNN
F 2 "" H 4650 4000 60  0001 C CNN
F 3 "" H 4650 4000 60  0001 C CNN
	1    4650 4000
	0    1    1    0   
$EndComp
$Comp
L R-RESCUE-Player R2
U 1 1 4B5B37F6
P 4650 3150
F 0 "R2" V 4730 3150 50  0000 C CNN
F 1 "200" V 4650 3150 50  0000 C CNN
F 2 "" H 4650 3150 60  0001 C CNN
F 3 "" H 4650 3150 60  0001 C CNN
	1    4650 3150
	0    1    1    0   
$EndComp
$Comp
L R-RESCUE-Player R1
U 1 1 4B5B37EF
P 4650 2300
F 0 "R1" V 4730 2300 50  0000 C CNN
F 1 "200" V 4650 2300 50  0000 C CNN
F 2 "" H 4650 2300 60  0001 C CNN
F 3 "" H 4650 2300 60  0001 C CNN
	1    4650 2300
	0    1    1    0   
$EndComp
$Comp
L PHTRANS U4
U 1 1 4B5B37B7
P 5600 5050
F 0 "U4" H 5550 5400 70  0000 C CNN
F 1 "CNY74-4" H 5550 4700 70  0000 C CNN
F 2 "" H 5600 5050 60  0001 C CNN
F 3 "" H 5600 5050 60  0001 C CNN
	1    5600 5050
	1    0    0    -1  
$EndComp
$Comp
L PHTRANS U3
U 1 1 4B5B37B5
P 5600 4200
F 0 "U3" H 5550 4550 70  0000 C CNN
F 1 "CNY74-4" H 5550 3850 70  0000 C CNN
F 2 "" H 5600 4200 60  0001 C CNN
F 3 "" H 5600 4200 60  0001 C CNN
	1    5600 4200
	1    0    0    -1  
$EndComp
$Comp
L PHTRANS U2
U 1 1 4B5B37B3
P 5600 3350
F 0 "U2" H 5550 3700 70  0000 C CNN
F 1 "CNY74-4" H 5550 3000 70  0000 C CNN
F 2 "" H 5600 3350 60  0001 C CNN
F 3 "" H 5600 3350 60  0001 C CNN
	1    5600 3350
	1    0    0    -1  
$EndComp
$Comp
L PHTRANS U1
U 1 1 4B5B37A9
P 5600 2500
F 0 "U1" H 5550 2850 70  0000 C CNN
F 1 "CNY74-4" H 5550 2150 70  0000 C CNN
F 2 "" H 5600 2500 60  0001 C CNN
F 3 "" H 5600 2500 60  0001 C CNN
	1    5600 2500
	1    0    0    -1  
$EndComp
$EndSCHEMATC
