;Authors: 
;        KALOGIANNIS PANAGIOTIS
;        MOUSTAKAS CHARES


.include "m16def.inc"

.def low_byte_ocr = r22
.def five_per =r24
.def sumOfstack= r14

.cseg
rjmp init
reti
reti
reti
reti
reti
reti
reti
rjmp t2_ovf
reti
reti
reti
reti
reti
reti
reti
reti
reti
rjmp t0_ovf
reti
reti
reti
reti
reti
reti
reti
reti
reti
reti
reti
reti
reti
rjmp capture_event_3 ;32


init:

clr sumOfstack

ldi r16,LOW(RAMEND)
out SPL,r16
ldi r16,HIGH(RAMEND)
out SPH,r16

ldi r16,0xFF ;make PORTB output for LEDS
out DDRB,r16


ldi r16,0b00110000
out DDRD,r16 ;make PORTD input for switches except for pin 4 which is pwm pin and make it output

clr r16
out OCR1AH,r16

ldi r16,240 ;TOP value so that with a step of 12 i can have 5% division
out OCR1AL,r16

clr r16
out OCR1BH,r16

ldi low_byte_ocr,48 ;20
out OCR1BL,low_byte_ocr

ldi r16,0b00100011 ;normal PWM 8-bit with OCR1A as TOP value
out TCCR1A,r16

ldi r16,0b00011010 ;without prescaler and start timer
out TCCR1B,r16

ldi r16 ,0b00100000
out ETIMSK,r16

ldi five_per,12


button:
in r20,PIND
tst r20
brlt no_display
pop XL
pop XH
rjmp display_values

no_display:
//com r20;simulator purpose
sbrc r20,0
rjmp next
ldi r23,5
ldi r17,0b11111110
rjmp next1

next:
sbrc r20,1
rjmp button
ldi r17,0b11111101
ldi r23,10
next1:


clr r21
schmit_trigger:
in r20,PIND
//com r20 ;simulator purpose
or r20,r17
cp r20,r17
brne button 
inc r21
cpi r21,20 //adjustable for solid result  ********************************
brne schmit_trigger

button_tilda:
clr r21
wait_unhold_button:
in r20,PIND
//com r20;simulator purpose
or r20,r17
cp r20,r17
breq button_tilda

inc r21
cpi r21,20 //adjustable for solid result *********************************
brne wait_unhold_button

cpi r23,5
breq incr_duty_cycle
cpi r23,10
breq decr_duty_cycle




incr_duty_cycle :
	inc sumOfstack
	ldi r17,5
	sei
	rjmp wait

continue_0:
	 				
	cpi low_byte_ocr,240
	breq button
	ADD low_byte_ocr,five_per
	OUT OCR1BL,low_byte_ocr
	RJMP button

decr_duty_cycle :
	inc sumOfstack
	ldi r17,5
	sei
	rjmp wait
	
continue_1:	

	tst low_byte_ocr
	breq button
	SUB low_byte_ocr,five_per 
	OUT OCR1BL,low_byte_ocr

	RJMP button





capture_event_3:
cpi r17,5
brne next_3
clr r16
out TCNT3H,r16 ;restart timer with the first pulse
out TCNT3L,r16

next_3:
dec r17
brne next1_3

in r17,ICR3L ;number of cycles for 1/8 of period so no division with 8 needed for correct period in microseconds
com r17 ;negative logic.

in r16,ICR3H
com r16;negative logic


push r17
push r16


cpi r23,5
breq continue_0
cpi r23,10
breq continue_1


next1_3:reti




display_values: 
	rcall button7
	clr r16 
	out PORTB,r16
	
	tst sumOfstack
	breq init	

	pop r18
	pop r17	 
	
	dec sumOfstack
		

	rcall button7 
	out PORTB,r17
	rcall button7 
	out PORTB,r18
	rjmp display_values





button7:

in r20,PIND
com r20;simulator purpose
tst r20
brlt button7 ;negative logic wait for sw7 to get pressed 

clr r21
schmit_trigger7:
in r20,PIND
com r20 ;simulator purpose
tst r20
brlt button7 
inc r21
cpi r21,20 //adjustable for solid result  ********************************
brne schmit_trigger7

button_tilda7: 
clr r21
wait_unhold_button7: //TEST IF SW7 ONLY IS UNPRESSED
in r20,PIND
com r20;simulator purpose
tst r20
brge button_tilda7 
inc r21
cpi r21,20 //adjustable for solid result *********************************
brne wait_unhold_button7

ret //end button7




wait:rjmp wait
