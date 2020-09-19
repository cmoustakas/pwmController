.include "m16def.inc"

.def low_byte_ocr = r22
.def five_per =r24

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


init:



ldi r16,LOW(RAMEND)
out SPL,r16
ldi r16,HIGH(RAMEND)
out SPH,r16

ldi r16,0xFF ;make PORTB output for LEDS
out DDRB,r16

//cbi PORTD,5

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

ldi r16,0b00010010 ;without prescaler and start timer
out TCCR1B,r16

ldi five_per,12

clr r25;counter for 158 ovfs for 10 sec

sei;
clr r3
clr r25;
clr r26;
ldi r16,(1<<CS02) | (1<<CS00);
out TCCR2,r16;
ldi r16,0b01000000;
out TIMSK,r16;
//sbi TIMSK,6;
rjmp B2;



B2:rjmp B2


incr_duty_cycle : 				
	cpi low_byte_ocr,240
	breq button
	ADD low_byte_ocr,five_per
	OUT OCR1BL,low_byte_ocr
	ret
	

decr_duty_cycle :
	tst low_byte_ocr
	breq button
	SUB low_byte_ocr,five_per 
	OUT OCR1BL,low_byte_ocr
	ret
	


t0_ovf:

	inc r25

	cpi r25,158;10 sec
	brne exit_t0
	
	com r3
	clr r25
	out TCCR0,r25
	out TCNT0,r25
	ldi r16,0b01000000
	out TIMSK,r16
	//cbi TIMSK,0
	//sbi TIMSK,6
	ldi r16,0b00000101
	out TCCR2,r16


	exit_t0:reti
	
	t2_ovf:
	push r16
	in r16,SREG
	push r16

	inc r25
	cpi r25,70
	brne exit_t2
	inc r26 //gia 10 fores
	clr r25
	tst r3 //auksomeiwsh
	brne dec_pwm
	rcall incr_duty_cycle
	rjmp label
dec_pwm:
	rcall decr_duty_cycle

label:
	cpi r26,10
	brne exit_t2

	clr r26
	ldi r16,0b00000001
	out TIMSK,r16
	//cbi TIMSK,6
	clr r25
	out TCCR2,r25
	out TCNT2,r25
	//sbi TIMSK,0
	ldi r16,0b00000101
	out TCCR0,r16
	//thelw na apenergopoihsw afton kai na energopoihsw ton allo timer gia 10 sec metrish

	exit_t2:
	pop r16
	out SREG,r16
	pop r16

	reti
