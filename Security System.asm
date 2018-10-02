;The operation of CCP2 module in PWM mode is demonstrated
;this example defines a period of 100 us and 50% of duty cycle,
;that is, 50 us
;the 10-bit number of the duty is 200 and the number for PR2 is 99
;the number 200 requires that 50 be loaded into CCP2RL
;PIC18F is running at 4MHz with the internal oscillator
;PWM signal is supplied by RC1, which is controlled by RB0
;******************Header Files******************************
list	    p=18f4550        ; list directive to define processor
#include    "p18f4550.inc"

;*****************Configuration Bits******************************
; PIC18F4550 Configuration Bit Settings

; ASM source line config statements

;#include "p18F4550.inc"

; CONFIG1L
  CONFIG  PLLDIV = 1            ; PLL Prescaler Selection bits (No prescale (4 MHz oscillator input drives PLL directly))
  CONFIG  CPUDIV = OSC1_PLL2    ; System Clock Postscaler Selection bits ([Primary Oscillator Src: /1][96 MHz PLL Src: /2])
  CONFIG  USBDIV = 1            ; USB Clock Selection bit (used in Full-Speed USB mode only; UCFG:FSEN = 1) (USB clock source comes directly from the primary oscillator block with no postscale)

; CONFIG1H
  CONFIG  FOSC = INTOSC_HS      ; Oscillator Selection bits (Internal oscillator, HS oscillator used by USB (INTHS))
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
  CONFIG  IESO = OFF            ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

; CONFIG2L
  CONFIG  PWRT = OFF            ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  BOR = OFF             ; Brown-out Reset Enable bits (Brown-out Reset disabled in hardware and software)
  CONFIG  BORV = 3              ; Brown-out Reset Voltage bits (Minimum setting 2.05V)
  CONFIG  VREGEN = OFF          ; USB Voltage Regulator Enable bit (USB voltage regulator disabled)

; CONFIG2H
  CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
  CONFIG  WDTPS = 32768         ; Watchdog Timer Postscale Select bits (1:32768)

; CONFIG3H
  CONFIG  CCP2MX = ON           ; CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
  CONFIG  PBADEN = OFF          ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as digital I/O on Reset)
  CONFIG  LPT1OSC = OFF         ; Low-Power Timer 1 Oscillator Enable bit (Timer1 configured for higher power operation)
  CONFIG  MCLRE = ON            ; MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)

; CONFIG4L
  CONFIG  STVREN = OFF          ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will not cause Reset)
  CONFIG  LVP = OFF             ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)
  CONFIG  ICPRT = OFF           ; Dedicated In-Circuit Debug/Programming Port (ICPORT) Enable bit (ICPORT disabled)
  CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

; CONFIG5L
  CONFIG  CP0 = OFF             ; Code Protection bit (Block 0 (000800-001FFFh) is not code-protected)
  CONFIG  CP1 = OFF             ; Code Protection bit (Block 1 (002000-003FFFh) is not code-protected)
  CONFIG  CP2 = OFF             ; Code Protection bit (Block 2 (004000-005FFFh) is not code-protected)
  CONFIG  CP3 = OFF             ; Code Protection bit (Block 3 (006000-007FFFh) is not code-protected)

; CONFIG5H
  CONFIG  CPB = OFF             ; Boot Block Code Protection bit (Boot block (000000-0007FFh) is not code-protected)
  CONFIG  CPD = OFF             ; Data EEPROM Code Protection bit (Data EEPROM is not code-protected)

; CONFIG6L
  CONFIG  WRT0 = OFF            ; Write Protection bit (Block 0 (000800-001FFFh) is not write-protected)
  CONFIG  WRT1 = OFF            ; Write Protection bit (Block 1 (002000-003FFFh) is not write-protected)
  CONFIG  WRT2 = OFF            ; Write Protection bit (Block 2 (004000-005FFFh) is not write-protected)
  CONFIG  WRT3 = OFF            ; Write Protection bit (Block 3 (006000-007FFFh) is not write-protected)

; CONFIG6H
  CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) are not write-protected)
  CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot block (000000-0007FFh) is not write-protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM is not write-protected)

; CONFIG7L
  CONFIG  EBTR0 = OFF           ; Table Read Protection bit (Block 0 (000800-001FFFh) is not protected from table reads executed in other blocks)
  CONFIG  EBTR1 = OFF           ; Table Read Protection bit (Block 1 (002000-003FFFh) is not protected from table reads executed in other blocks)
  CONFIG  EBTR2 = OFF           ; Table Read Protection bit (Block 2 (004000-005FFFh) is not protected from table reads executed in other blocks)
  CONFIG  EBTR3 = OFF           ; Table Read Protection bit (Block 3 (006000-007FFFh) is not protected from table reads executed in other blocks)

; CONFIG7H
  CONFIG  EBTRB = OFF           ; Boot Block Table Read Protection bit (Boot block (000000-0007FFh) is not protected from table reads executed in other blocks)


;****************Variables Definition*********************************
CONSTANT	PERIOD = d'99'
CONSTANT	DUTY = d'50'
TEMPORAL  EQU 0x21		;GPR that contains the first number
Result    EQU 0x23		;GPR that contains the result number
Exception EQU 0x24		;GPR that contains the error number
Temporal  EQU 0x25		;GPR that temporarily stores PORTD
;****************Main code*****************************
			ORG     0x000             	;reset vector
  			GOTO    MAIN              	;go to the main routine


INITIALIZE:
			CALL	CONFIGURE_PWM2
			MOVLW	b'00000000'
			MOVWF	TEMPORAL
			MOVLW	b'00001111'
			MOVWF	TRISB			; PORTB IS AN INPUT
			MOVWF	TRISD			; PORTD IS HALF AN INPUT AND HALF AN AOUTPUT
			CLRF	PORTD
			CLRF	PORTB
			;BSF	TRISB,	0		;RB0 is input
			BSF	OSCCON, IRCF0		;Internal oscillator running at 4 MHz
			BCF	OSCCON, IRCF1
			BSF	OSCCON, IRCF2
			BSF	PORTD,4
			BSF	PORTD,5
			BSF	PORTD,6
			RETURN				;end of initialization subroutine

MAIN:	
			CALL 	INITIALIZE

MAQUINA_ESTADO_1:
    ;CHECK RB0, IF SET, IT MEANS THE BUTTON HAS BEEN PRESSED. IF CLEAR, IT WAITS UNTIL IT IS PRESSED
			BTFSC	PORTB,	0
			GOTO	MAQUINA_ESTADO_2
			GOTO	MAQUINA_ESTADO_1
			
MAQUINA_ESTADO_2:	
    ;CHECK RB1, IF SET, IT MEANS THE BUTTON HAS BEEN PRESSED. IF CLEAR, IT WAITS UNTIL IT IS PRESSED
			BTFSC	PORTB,	1
			GOTO	MAQUINA_ESTADO_3
			GOTO	MAQUINA_ESTADO_2
			
MAQUINA_ESTADO_3:
    ;CHECK RB2, IF SET, IT MEANS THE BUTTON HAS BEEN PRESSED. IF CLEAR, IT WAITS UNTIL IT IS PRESSED
			BTFSC	PORTB,	2
			GOTO	MAQUINA_ESTADO_4
			GOTO	MAQUINA_ESTADO_3
			
MAQUINA_ESTADO_4:
    ;CHECK RB3, IF SET, IT MEANS THE BUTTON HAS BEEN PRESSED. IF CLEAR, IT WAITS UNTIL IT IS PRESSED
			BTFSC	PORTB,	3
			GOTO	MAQUINA_ESTADO_5
			GOTO	MAQUINA_ESTADO_4
			
MAQUINA_ESTADO_5:
    ;CHECK THE INPUT SIGNALS, TO SEE IF THERE IS AN INTRUDER
    
			BTFSC	PORTD,0
			GOTO	MAQUINA_ESTADO_6
			BTFSC	PORTD,1
			GOTO	MAQUINA_ESTADO_6
			BTFSC	PORTD,2
			GOTO	MAQUINA_ESTADO_6
			GOTO	MAQUINA_ESTADO_5
	
MAQUINA_ESTADO_6:
    ;CHECK RB0, IF SET, IT MEANS THE BUTTON HAS BEEN PRESSED. IF CLEAR, IT WAITS UNTIL IT IS PRESSED
			BCF	PORTD,0
			BCF	PORTD,1
			BCF	PORTD,2
			BCF	TRISC,1
			BTFSC	PORTB,	0
			GOTO	MAQUINA_ESTADO_7
			GOTO	MAQUINA_ESTADO_6
			
MAQUINA_ESTADO_7:	
    ;CHECK RB1, IF SET, IT MEANS THE BUTTON HAS BEEN PRESSED. IF CLEAR, IT WAITS UNTIL IT IS PRESSED
			BTFSC	PORTB,	1
			GOTO	MAQUINA_ESTADO_8
			GOTO	MAQUINA_ESTADO_7
			
MAQUINA_ESTADO_8:
    ;CHECK RB2, IF SET, IT MEANS THE BUTTON HAS BEEN PRESSED. IF CLEAR, IT WAITS UNTIL IT IS PRESSED
			BTFSC	PORTB,	2
			GOTO	MAQUINA_ESTADO_9
			GOTO	MAQUINA_ESTADO_8
			
MAQUINA_ESTADO_9:
    ;CHECK RB3, IF SET, IT MEANS THE BUTTON HAS BEEN PRESSED. IF CLEAR, IT WAITS UNTIL IT IS PRESSED
			BTFSC	PORTB,	3
			GOTO	MAQUINA_ESTADO_10
			GOTO	MAQUINA_ESTADO_9
MAQUINA_ESTADO_10:
			BSF	TRISC,1
			GOTO	MAQUINA_ESTADO_1
CONFIGURE_PWM2:
			;configure Timer2 and CCP2 in PWM mode
			MOVLW	PERIOD
			MOVWF	PR2
			BSF	TRISC, 1		;making RC1 input PWM signal is off
			MOVLW	DUTY
			MOVWF	CCPR2L
			MOVLW	0x0F
			MOVWF	CCP2CON			;PWM mode selected and bits 5 and 4 cleared
			MOVLW	0x04
			MOVWF	T2CON			;postcaler and prescaler are 1:1 and Timer2 is on
			RETURN


			END                       	; end of program




