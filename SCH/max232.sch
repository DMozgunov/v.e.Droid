EESchema Schematic File Version 2  date 01.02.2010 21:48:20
LIBS:power,device,transistors,conn,linear,regul,74xx,cmos4000,adc-dac,memory,xilinx,special,microcontrollers,dsp,microchip,analog_switches,motorola,texas,intel,audio,interface,digital-audio,philips,display,cypress,siliconi,opto,atmel,contrib,valves
EELAYER 43  0
EELAYER END
$Descr A4 11700 8267
Sheet 1 1
Title ""
Date "1 feb 2010"
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Wire Wire Line
	4700 4350 5150 4350
Wire Wire Line
	4800 4050 4800 4150
Wire Wire Line
	5150 4150 5050 4150
Wire Wire Line
	5050 4150 5050 4250
Wire Wire Line
	7650 3500 7650 3450
Wire Wire Line
	7650 3450 7000 3450
Wire Wire Line
	7050 4550 6850 4550
Wire Wire Line
	6850 4550 6850 4350
Wire Wire Line
	6850 4350 6750 4350
Wire Wire Line
	7200 3450 7200 3350
Wire Wire Line
	6750 3550 7000 3550
Wire Wire Line
	7000 3550 7000 3450
Wire Wire Line
	5050 3850 5150 3850
Wire Wire Line
	5050 2950 5150 2950
Wire Wire Line
	5050 3450 5150 3450
Wire Wire Line
	5050 3350 5150 3350
Wire Wire Line
	7200 3850 6750 3850
Wire Wire Line
	6750 3350 6850 3350
Connection ~ 6850 2950
Connection ~ 7200 3450
Wire Wire Line
	6750 4150 6950 4150
Wire Wire Line
	6950 4150 6950 4350
Wire Wire Line
	6950 4350 7050 4350
Wire Wire Line
	6950 5050 6950 4950
Wire Wire Line
	6950 4950 7050 4950
Wire Wire Line
	6750 2950 7650 2950
Wire Wire Line
	7650 2950 7650 2850
Wire Wire Line
	4800 4150 4700 4150
Wire Wire Line
	5050 4250 4700 4250
$Comp
L GND G?
U 1 1 4B671F78
P 6950 5150
F 0 "G?" H 6960 5510 60  0001 C CNN
F 1 "GND" H 6960 5080 60  0000 C CNN
	1    6950 5150
	1    0    0    -1  
$EndComp
$Comp
L GND G?
U 1 1 4B671E42
P 7650 3600
F 0 "G?" H 7660 3960 60  0001 C CNN
F 1 "GND" H 7660 3530 60  0000 C CNN
	1    7650 3600
	1    0    0    -1  
$EndComp
$Comp
L +5V #PWR?
U 1 1 4B671DB5
P 7650 2850
F 0 "#PWR?" H 7650 2940 20  0001 C CNN
F 1 "+5V" H 7650 2940 30  0000 C CNN
	1    7650 2850
	1    0    0    -1  
$EndComp
$Comp
L GND G?
U 1 1 4B671DA7
P 4800 3950
F 0 "G?" H 4810 4310 60  0001 C CNN
F 1 "GND" H 4810 3880 60  0000 C CNN
	1    4800 3950
	1    0    0    1   
$EndComp
$Comp
L CONN_3 P1
U 1 1 4B671CFC
P 4350 4250
F 0 "P1" V 4300 4250 50  0000 C CNN
F 1 "RS232" H 4350 4050 40  0000 C CNN
	1    4350 4250
	-1   0    0    1   
$EndComp
$Comp
L DB9 P2
U 1 1 4B671CEF
P 7500 4550
F 0 "P2" H 7500 5100 70  0000 C CNN
F 1 "DB9" H 7500 4000 70  0000 C CNN
	1    7500 4550
	1    0    0    1   
$EndComp
$Comp
L CP1 C?
U 1 1 4B671CBF
P 7200 3650
F 0 "C?" H 7250 3750 50  0000 L CNN
F 1 "1mkF" H 7250 3550 50  0000 L CNN
	1    7200 3650
	1    0    0    -1  
$EndComp
$Comp
L CP1 C?
U 1 1 4B671CBD
P 6850 3150
F 0 "C?" H 6900 3250 50  0000 L CNN
F 1 "1mkF" H 6900 3050 50  0000 L CNN
	1    6850 3150
	-1   0    0    1   
$EndComp
$Comp
L CP1 C?
U 1 1 4B671CB5
P 7200 3150
F 0 "C?" H 7250 3250 50  0000 L CNN
F 1 "1mkF" H 7250 3050 50  0000 L CNN
	1    7200 3150
	1    0    0    -1  
$EndComp
$Comp
L CP1 C?
U 1 1 4B671CB3
P 5050 3650
F 0 "C?" H 5100 3750 50  0000 L CNN
F 1 "1mkF" H 5100 3550 50  0000 L CNN
	1    5050 3650
	1    0    0    -1  
$EndComp
$Comp
L CP1 C?
U 1 1 4B671CB0
P 5050 3150
F 0 "C?" H 5100 3250 50  0000 L CNN
F 1 "1mkF" H 5100 3050 50  0000 L CNN
	1    5050 3150
	1    0    0    -1  
$EndComp
$Comp
L MAX232 IC1
U 1 1 4B671C8D
P 5950 3650
F 0 "IC1" H 5950 4500 70  0000 C CNN
F 1 "MAX232" H 5950 2800 70  0000 C CNN
	1    5950 3650
	1    0    0    -1  
$EndComp
$EndSCHEMATC
