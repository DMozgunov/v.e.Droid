EESchema Schematic File Version 4
LIBS:Amplifier-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Wire Wire Line
	4800 3200 4750 3200
Wire Wire Line
	4750 3200 4750 3300
Wire Wire Line
	4750 3300 4350 3300
Connection ~ 4250 2850
Wire Wire Line
	4200 2850 4250 2850
Connection ~ 4750 2850
Wire Wire Line
	5450 2850 4750 2850
Wire Wire Line
	4900 3400 4750 3400
Wire Wire Line
	6800 3000 7050 3000
Wire Wire Line
	7050 3000 7050 2900
Wire Wire Line
	7050 2900 7100 2900
Wire Wire Line
	7100 3550 7050 3550
Wire Wire Line
	7050 3550 7050 3400
Wire Wire Line
	7050 3400 6800 3400
Connection ~ 4750 3950
Wire Wire Line
	4750 3400 4750 3950
Wire Wire Line
	4750 4200 5000 4200
Connection ~ 4350 4200
Wire Wire Line
	4350 4250 4350 4200
Wire Wire Line
	5450 3950 5500 3950
Wire Wire Line
	6900 3950 6900 3600
Wire Wire Line
	5200 3600 5400 3600
Wire Wire Line
	5400 3600 5400 3500
Wire Wire Line
	5400 3500 5600 3500
Wire Wire Line
	5500 4250 5500 4200
Connection ~ 5550 3700
Wire Wire Line
	5550 3700 5550 3100
Wire Wire Line
	5550 3100 5600 3100
Connection ~ 6900 3600
Wire Wire Line
	6800 3600 6900 3600
Wire Wire Line
	5600 3700 5550 3700
Wire Wire Line
	5200 3700 5200 3750
Wire Wire Line
	6900 3200 6800 3200
Wire Wire Line
	5600 3400 5450 3400
Wire Wire Line
	5500 3600 5600 3600
Connection ~ 5500 3950
Wire Wire Line
	5400 4200 5500 4200
Connection ~ 5500 4200
Wire Wire Line
	5600 3300 5400 3300
Wire Wire Line
	5400 3300 5400 3200
Wire Wire Line
	5400 3200 5200 3200
Wire Wire Line
	4550 4150 4550 4200
Wire Wire Line
	4750 3950 4950 3950
Wire Wire Line
	4550 3600 4800 3600
Wire Wire Line
	4150 3500 4200 3500
Wire Wire Line
	4200 3500 4200 4200
Wire Wire Line
	4200 4200 4350 4200
Wire Wire Line
	6800 3700 7050 3700
Wire Wire Line
	7050 3700 7050 3750
Wire Wire Line
	7050 3750 7100 3750
Wire Wire Line
	7100 3100 7050 3100
Wire Wire Line
	7050 3100 7050 3300
Wire Wire Line
	7050 3300 6800 3300
Connection ~ 5450 3400
Wire Wire Line
	4150 3400 4550 3400
Wire Wire Line
	4550 3400 4550 3600
Connection ~ 4550 3600
Wire Wire Line
	4350 3300 4350 3650
Connection ~ 4350 3300
Wire Wire Line
	4700 2700 4750 2700
Wire Wire Line
	4750 2700 4750 2850
Wire Wire Line
	4750 3000 4700 3000
Wire Wire Line
	4300 2700 4250 2700
Wire Wire Line
	4250 2700 4250 2850
Wire Wire Line
	4250 3000 4300 3000
Wire Wire Line
	5450 2750 5450 2850
Connection ~ 5450 2850
$Comp
L Amplifier-rescue:GND-RESCUE-Amplifier G?
U 1 1 4B672F91
P 4100 2850
F 0 "G?" H 4110 3210 60  0001 C CNN
F 1 "GND" H 4110 2780 60  0000 C CNN
F 2 "" H 4100 2850 60  0001 C CNN
F 3 "" H 4100 2850 60  0001 C CNN
	1    4100 2850
	0    1    1    0   
$EndComp
$Comp
L Amplifier-rescue:SPEAKER SP2
U 1 1 4B672EE1
P 7400 3650
F 0 "SP2" H 7300 3900 70  0000 C CNN
F 1 "1W" H 7300 3400 70  0000 C CNN
F 2 "" H 7400 3650 60  0001 C CNN
F 3 "" H 7400 3650 60  0001 C CNN
	1    7400 3650
	1    0    0    -1  
$EndComp
$Comp
L Amplifier-rescue:SPEAKER SP1
U 1 1 4B672EDB
P 7400 3000
F 0 "SP1" H 7300 3250 70  0000 C CNN
F 1 "1W" H 7300 2750 70  0000 C CNN
F 2 "" H 7400 3000 60  0001 C CNN
F 3 "" H 7400 3000 60  0001 C CNN
	1    7400 3000
	1    0    0    1   
$EndComp
$Comp
L Amplifier-rescue:CONN_3 JP1
U 1 1 4B672E8C
P 3800 3400
F 0 "JP1" V 3750 3400 50  0000 C CNN
F 1 "Sound IN" V 3950 3400 40  0000 C CNN
F 2 "" H 3800 3400 60  0001 C CNN
F 3 "" H 3800 3400 60  0001 C CNN
	1    3800 3400
	-1   0    0    1   
$EndComp
$Comp
L Amplifier-rescue:GND-RESCUE-Amplifier G?
U 1 1 4B672C6E
P 4350 4350
F 0 "G?" H 4360 4710 60  0001 C CNN
F 1 "GND" H 4360 4280 60  0000 C CNN
F 2 "" H 4350 4350 60  0001 C CNN
F 3 "" H 4350 4350 60  0001 C CNN
	1    4350 4350
	1    0    0    -1  
$EndComp
$Comp
L Amplifier-rescue:CP1-RESCUE-Amplifier C1
U 1 1 4B672AEB
P 4500 2700
F 0 "C1" V 4550 2850 50  0000 L CNN
F 1 "100mkF" V 4300 2700 50  0000 L CNN
F 2 "" H 4500 2700 60  0001 C CNN
F 3 "" H 4500 2700 60  0001 C CNN
	1    4500 2700
	0    1    1    0   
$EndComp
$Comp
L Amplifier-rescue:GND-RESCUE-Amplifier G?
U 1 1 4B672AD1
P 5500 4350
F 0 "G?" H 5510 4710 60  0001 C CNN
F 1 "GND" H 5510 4280 60  0000 C CNN
F 2 "" H 5500 4350 60  0001 C CNN
F 3 "" H 5500 4350 60  0001 C CNN
	1    5500 4350
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR?
U 1 1 4B672AC8
P 5450 2750
F 0 "#PWR?" H 5450 2840 20  0001 C CNN
F 1 "+5V" H 5450 2840 30  0000 C CNN
F 2 "" H 5450 2750 60  0001 C CNN
F 3 "" H 5450 2750 60  0001 C CNN
	1    5450 2750
	1    0    0    -1  
$EndComp
$Comp
L Amplifier-rescue:RVAR R1
U 1 1 4B672AB8
P 5200 3950
F 0 "R1" V 5280 3900 50  0000 C CNN
F 1 "10k" V 5080 4080 50  0000 C CNN
F 2 "" H 5200 3950 60  0001 C CNN
F 3 "" H 5200 3950 60  0001 C CNN
	1    5200 3950
	0    1    1    0   
$EndComp
$Comp
L Amplifier-rescue:R-RESCUE-Amplifier R4
U 1 1 4B672AA5
P 5150 3400
F 0 "R4" V 5230 3400 50  0000 C CNN
F 1 "27k" V 5150 3400 50  0000 C CNN
F 2 "" H 5150 3400 60  0001 C CNN
F 3 "" H 5150 3400 60  0001 C CNN
	1    5150 3400
	0    1    1    0   
$EndComp
$Comp
L Amplifier-rescue:R-RESCUE-Amplifier R3
U 1 1 4B672AA1
P 4550 3900
F 0 "R3" V 4630 3900 50  0000 C CNN
F 1 "4k7" V 4550 3900 50  0000 C CNN
F 2 "" H 4550 3900 60  0001 C CNN
F 3 "" H 4550 3900 60  0001 C CNN
	1    4550 3900
	1    0    0    -1  
$EndComp
$Comp
L Amplifier-rescue:R-RESCUE-Amplifier R2
U 1 1 4B672A9D
P 4350 3900
F 0 "R2" V 4430 3900 50  0000 C CNN
F 1 "4k7" V 4350 3900 50  0000 C CNN
F 2 "" H 4350 3900 60  0001 C CNN
F 3 "" H 4350 3900 60  0001 C CNN
	1    4350 3900
	1    0    0    -1  
$EndComp
$Comp
L Amplifier-rescue:CP1-RESCUE-Amplifier C?
U 1 1 4B672A94
P 5200 4200
F 0 "C?" H 5250 4300 50  0000 L CNN
F 1 "1mkF" H 5250 4100 50  0000 L CNN
F 2 "" H 5200 4200 60  0001 C CNN
F 3 "" H 5200 4200 60  0001 C CNN
	1    5200 4200
	0    -1   1    0   
$EndComp
$Comp
L Amplifier-rescue:C-RESCUE-Amplifier C3
U 1 1 4B672A86
P 5000 3200
F 0 "C3" V 5050 3300 50  0000 L CNN
F 1 "100nF" V 5150 3150 50  0000 L CNN
F 2 "" H 5000 3200 60  0001 C CNN
F 3 "" H 5000 3200 60  0001 C CNN
	1    5000 3200
	0    1    -1   0   
$EndComp
$Comp
L Amplifier-rescue:C-RESCUE-Amplifier C4
U 1 1 4B672A81
P 5000 3600
F 0 "C4" V 5050 3700 50  0000 L CNN
F 1 "100nF" V 5150 3550 50  0000 L CNN
F 2 "" H 5000 3600 60  0001 C CNN
F 3 "" H 5000 3600 60  0001 C CNN
	1    5000 3600
	0    1    1    0   
$EndComp
$Comp
L Amplifier-rescue:C-RESCUE-Amplifier C2
U 1 1 4B672A7F
P 4500 3000
F 0 "C2" V 4550 3150 50  0000 L CNN
F 1 "100nF" V 4650 3000 50  0000 L CNN
F 2 "" H 4500 3000 60  0001 C CNN
F 3 "" H 4500 3000 60  0001 C CNN
	1    4500 3000
	0    1    1    0   
$EndComp
$Comp
L Amplifier-rescue:TDA7053A IC1
U 1 1 4B672A4F
P 6200 3350
F 0 "IC1" H 6400 3800 60  0000 C CNN
F 1 "TDA7053A" H 6200 2900 60  0000 C CNN
F 2 "" H 6200 3350 60  0001 C CNN
F 3 "" H 6200 3350 60  0001 C CNN
	1    6200 3350
	1    0    0    -1  
$EndComp
Wire Wire Line
	4250 2850 4250 3000
Wire Wire Line
	4750 2850 4750 3000
Wire Wire Line
	4750 3950 4750 4200
Wire Wire Line
	4350 4200 4350 4150
Wire Wire Line
	4350 4200 4550 4200
Wire Wire Line
	5550 3700 5200 3700
Wire Wire Line
	6900 3600 6900 3200
Wire Wire Line
	5500 3950 6900 3950
Wire Wire Line
	5500 3950 5500 3600
Wire Wire Line
	5500 4200 5500 3950
Wire Wire Line
	5450 3400 5400 3400
Wire Wire Line
	4550 3600 4550 3650
Wire Wire Line
	4350 3300 4150 3300
Wire Wire Line
	5450 2850 5450 3400
$EndSCHEMATC
