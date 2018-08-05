EESchema Schematic File Version 2
LIBS:LineDetector-rescue
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
LIBS:LineDetector-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "Multifunction mobile robot platform line detector"
Date "30 oct 2009"
Rev ""
Comp "MAI, k.304, 10.2009"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Wire Wire Line
	4200 4450 4500 4450
Wire Wire Line
	4500 4450 4500 3550
Wire Wire Line
	4500 3550 5650 3550
Wire Wire Line
	4000 3450 5450 3450
Wire Wire Line
	5450 3450 5450 3050
Connection ~ 7700 5050
Wire Wire Line
	7700 4950 7700 5050
Connection ~ 6350 5050
Wire Wire Line
	6350 4950 6350 5050
Connection ~ 5000 5050
Wire Wire Line
	5000 4950 5000 5050
Connection ~ 3750 5050
Wire Wire Line
	3750 4950 3750 5050
Wire Wire Line
	5950 3050 5950 3450
Wire Wire Line
	5750 3050 5750 4450
Connection ~ 4200 3650
Connection ~ 4200 3450
Wire Wire Line
	4200 3450 4200 3900
Wire Wire Line
	3750 3650 3750 3900
Connection ~ 3400 3450
Wire Wire Line
	3400 3450 3500 3450
Connection ~ 3750 3750
Connection ~ 6800 3650
Wire Wire Line
	5000 3900 5000 3750
Wire Wire Line
	5450 3650 5450 3900
Wire Wire Line
	6800 4450 6650 4450
Wire Wire Line
	6650 4450 6650 3550
Wire Wire Line
	8150 3900 8150 3650
Wire Wire Line
	8150 4550 8150 4400
Wire Wire Line
	6800 4550 6800 4400
Wire Wire Line
	5450 4550 5450 4400
Wire Wire Line
	4200 4550 4200 4400
Wire Wire Line
	3750 4400 3750 4550
Wire Wire Line
	5000 4400 5000 4550
Wire Wire Line
	6350 4400 6350 4550
Wire Wire Line
	7700 4400 7700 4550
Wire Wire Line
	3750 3750 7700 3750
Wire Wire Line
	7700 3750 7700 3900
Connection ~ 4200 4450
Connection ~ 5450 4450
Connection ~ 6800 4450
Connection ~ 8150 4450
Wire Wire Line
	5750 4450 5450 4450
Wire Wire Line
	6800 3900 6800 3650
Connection ~ 5000 3750
Connection ~ 6350 3750
Wire Wire Line
	6350 3900 6350 3750
Connection ~ 5450 3650
Wire Wire Line
	8150 3650 4200 3650
Wire Wire Line
	5650 3550 5650 3050
Wire Wire Line
	5850 3050 5850 3550
Wire Wire Line
	5850 3550 6650 3550
Wire Wire Line
	8150 4950 8150 5050
Wire Wire Line
	8150 5050 3400 5050
Wire Wire Line
	3400 5050 3400 3200
Wire Wire Line
	4200 4950 4200 5050
Connection ~ 4200 5050
Wire Wire Line
	5450 4950 5450 5050
Connection ~ 5450 5050
Wire Wire Line
	6800 4950 6800 5050
Connection ~ 6800 5050
Wire Wire Line
	3400 3200 5550 3200
Wire Wire Line
	5550 3200 5550 3050
Wire Wire Line
	5950 3450 8000 3450
Wire Wire Line
	8000 3450 8000 4450
Wire Wire Line
	8000 4450 8150 4450
Text Notes 5980 2580 1    48   ~ 0
Out4
Text Notes 5880 2580 1    48   ~ 0
Out3
Text Notes 5780 2580 1    48   ~ 0
Out2
Text Notes 5680 2580 1    48   ~ 0
Out1
Text Notes 5580 2580 1    48   ~ 0
GND
Text Notes 5480 2580 1    48   ~ 0
+5V
$Comp
L R-RESCUE-LineDetector R9
U 1 1 4AEB5BC6
P 8150 4150
F 0 "R9" V 8230 4150 50  0000 C CNN
F 1 "12k" V 8150 4150 50  0000 C CNN
F 2 "" H 8150 4150 60  0001 C CNN
F 3 "" H 8150 4150 60  0001 C CNN
	1    8150 4150
	1    0    0    -1  
$EndComp
$Comp
L R-RESCUE-LineDetector R8
U 1 1 4AEB5BC5
P 7700 4150
F 0 "R8" V 7780 4150 50  0000 C CNN
F 1 "360" V 7700 4150 50  0000 C CNN
F 2 "" H 7700 4150 60  0001 C CNN
F 3 "" H 7700 4150 60  0001 C CNN
	1    7700 4150
	1    0    0    -1  
$EndComp
$Comp
L LED-RESCUE-LineDetector LED4
U 1 1 4AEB5BC4
P 7700 4750
F 0 "LED4" H 7700 4850 50  0000 C CNN
F 1 "LED" H 7700 4650 50  0000 C CNN
F 2 "" H 7700 4750 60  0001 C CNN
F 3 "" H 7700 4750 60  0001 C CNN
	1    7700 4750
	0    -1   1    0   
$EndComp
$Comp
L OPTO_NPN Q4
U 1 1 4AEB5BC3
P 8050 4750
F 0 "Q4" H 8200 4800 50  0000 L CNN
F 1 "BPW85C" H 8200 4650 50  0000 L CNN
F 2 "" H 8050 4750 60  0001 C CNN
F 3 "" H 8050 4750 60  0001 C CNN
	1    8050 4750
	1    0    0    -1  
$EndComp
$Comp
L R-RESCUE-LineDetector R3
U 1 1 4AEB5BBB
P 4200 4150
F 0 "R3" V 4280 4150 50  0000 C CNN
F 1 "12k" V 4200 4150 50  0000 C CNN
F 2 "" H 4200 4150 60  0001 C CNN
F 3 "" H 4200 4150 60  0001 C CNN
	1    4200 4150
	1    0    0    -1  
$EndComp
$Comp
L R-RESCUE-LineDetector R2
U 1 1 4AEB5BBA
P 3750 4150
F 0 "R2" V 3830 4150 50  0000 C CNN
F 1 "360" V 3750 4150 50  0000 C CNN
F 2 "" H 3750 4150 60  0001 C CNN
F 3 "" H 3750 4150 60  0001 C CNN
	1    3750 4150
	1    0    0    -1  
$EndComp
$Comp
L LED-RESCUE-LineDetector LED1
U 1 1 4AEB5BB9
P 3750 4750
F 0 "LED1" H 3750 4850 50  0000 C CNN
F 1 "LED" H 3750 4650 50  0000 C CNN
F 2 "" H 3750 4750 60  0001 C CNN
F 3 "" H 3750 4750 60  0001 C CNN
	1    3750 4750
	0    -1   1    0   
$EndComp
$Comp
L OPTO_NPN Q1
U 1 1 4AEB5BB8
P 4100 4750
F 0 "Q1" H 4250 4800 50  0000 L CNN
F 1 "BPW85C" H 4250 4650 50  0000 L CNN
F 2 "" H 4100 4750 60  0001 C CNN
F 3 "" H 4100 4750 60  0001 C CNN
	1    4100 4750
	1    0    0    -1  
$EndComp
$Comp
L R-RESCUE-LineDetector R7
U 1 1 4AEB5BAC
P 6800 4150
F 0 "R7" V 6880 4150 50  0000 C CNN
F 1 "12k" V 6800 4150 50  0000 C CNN
F 2 "" H 6800 4150 60  0001 C CNN
F 3 "" H 6800 4150 60  0001 C CNN
	1    6800 4150
	1    0    0    -1  
$EndComp
$Comp
L R-RESCUE-LineDetector R6
U 1 1 4AEB5BAB
P 6350 4150
F 0 "R6" V 6430 4150 50  0000 C CNN
F 1 "360" V 6350 4150 50  0000 C CNN
F 2 "" H 6350 4150 60  0001 C CNN
F 3 "" H 6350 4150 60  0001 C CNN
	1    6350 4150
	1    0    0    -1  
$EndComp
$Comp
L LED-RESCUE-LineDetector LED3
U 1 1 4AEB5BAA
P 6350 4750
F 0 "LED3" H 6350 4850 50  0000 C CNN
F 1 "LED" H 6350 4650 50  0000 C CNN
F 2 "" H 6350 4750 60  0001 C CNN
F 3 "" H 6350 4750 60  0001 C CNN
	1    6350 4750
	0    -1   1    0   
$EndComp
$Comp
L OPTO_NPN Q3
U 1 1 4AEB5BA9
P 6700 4750
F 0 "Q3" H 6850 4800 50  0000 L CNN
F 1 "BPW85C" H 6850 4650 50  0000 L CNN
F 2 "" H 6700 4750 60  0001 C CNN
F 3 "" H 6700 4750 60  0001 C CNN
	1    6700 4750
	1    0    0    -1  
$EndComp
$Comp
L CONN_6 P1
U 1 1 4AEB5AB7
P 5700 2700
F 0 "P1" V 5650 2700 60  0000 C CNN
F 1 "Line detector" V 5750 2700 60  0000 C CNN
F 2 "" H 5700 2700 60  0001 C CNN
F 3 "" H 5700 2700 60  0001 C CNN
	1    5700 2700
	0    -1   -1   0   
$EndComp
$Comp
L RVAR R1
U 1 1 4AEB5AA2
P 3750 3450
F 0 "R1" V 3830 3400 50  0000 C CNN
F 1 "500" V 3750 3450 50  0000 C CNN
F 2 "" H 3750 3450 60  0001 C CNN
F 3 "" H 3750 3450 60  0001 C CNN
	1    3750 3450
	0    -1   -1   0   
$EndComp
$Comp
L R-RESCUE-LineDetector R5
U 1 1 4AEB5A07
P 5450 4150
F 0 "R5" V 5530 4150 50  0000 C CNN
F 1 "12k" V 5450 4150 50  0000 C CNN
F 2 "" H 5450 4150 60  0001 C CNN
F 3 "" H 5450 4150 60  0001 C CNN
	1    5450 4150
	1    0    0    -1  
$EndComp
$Comp
L R-RESCUE-LineDetector R4
U 1 1 4AEB5A06
P 5000 4150
F 0 "R4" V 5080 4150 50  0000 C CNN
F 1 "360" V 5000 4150 50  0000 C CNN
F 2 "" H 5000 4150 60  0001 C CNN
F 3 "" H 5000 4150 60  0001 C CNN
	1    5000 4150
	1    0    0    -1  
$EndComp
$Comp
L LED-RESCUE-LineDetector LED2
U 1 1 4AEB59B1
P 5000 4750
F 0 "LED2" H 5000 4850 50  0000 C CNN
F 1 "LED" H 5000 4650 50  0000 C CNN
F 2 "" H 5000 4750 60  0001 C CNN
F 3 "" H 5000 4750 60  0001 C CNN
	1    5000 4750
	0    -1   1    0   
$EndComp
$Comp
L OPTO_NPN Q2
U 1 1 4AEB599D
P 5350 4750
F 0 "Q2" H 5500 4800 50  0000 L CNN
F 1 "BPW85C" H 5500 4650 50  0000 L CNN
F 2 "" H 5350 4750 60  0001 C CNN
F 3 "" H 5350 4750 60  0001 C CNN
	1    5350 4750
	1    0    0    -1  
$EndComp
$EndSCHEMATC
