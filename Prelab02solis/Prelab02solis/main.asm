//*********************************************************************
// Universidad del Valle de Guatemala
// IE2023: Programación de Microcontroladores
// Author : Thomas Solis
// Proyecto: Prelab 2
// Descripción: Contador de 4 bits con el timer0
// Hardware: ATmega328p
// Created: 09/02/2025 16:30:13
//*********************************************************************
// Encabezado
//*********************************************************************
.include "M328PDEF.inc"   
.cseg
.org 0x0000

LDI     R16, LOW(RAMEND)
OUT     SPL, R16
LDI     R17, HIGH(RAMEND)
OUT     SPH, R17

SETUP:
    ; Configurar el prescaler 
    LDI R16, (1 << CLKPCE)
    STS CLKPR, R16           
    LDI R16, 0b0000_0100
    STS CLKPR, R16            ; Configurar Prescaler a 16 (F_CPU = 1MHz)
    CALL INIT_TMR0            

    ; Configurar PC3 - PC0 como salidas 
    LDI     R16, 0b00001111   ; Configura PC0-PC3 como salida
    OUT     DDRC, R16         
    CLR     R21               
    CLR     R20               

// Loop Infinito
MAIN_LOOP:
    IN      R16, TIFR0         
    SBRS    R16, OCF0A         
    RJMP    MAIN_LOOP           

    SBI     TIFR0, OCF0A       

    INC     R20                 ; Incrementar contador de tiempo (10ms)
    CPI     R20, 10             ; Esperar 10 desbordes de 10ms (100ms)
    BRNE    MAIN_LOOP           ; Si no ha pasado 100ms, seguir esperando

    CLR     R20                 ; Reiniciar contador de tiempo
    INC     R21                 ; Incrementar el contador binario de 4 bits
    ANDI    R21, 0x0F           ; Mantener solo los 4 bits bajos (0-15)

    OUT     PORTC, R21          ; Mostrar en los LEDs PC0-PC3

    RJMP    MAIN_LOOP

// Subrutina de configuración del Timer0
INIT_TMR0:
    LDI     R16, 0              ; Reiniciar Timer0
    OUT     TCNT0, R16

    LDI     R16, 98             ; Valor para alcanzar 10ms con F_CPU=1MHz y prescaler 1024
    OUT     OCR0A, R16  

    LDI     R16, (1 << WGM01)   ; Modo CTC (Clear Timer on Compare Match)
    OUT     TCCR0A, R16

    LDI     R16, (1 << CS02) | (1 << CS00)  ; Configurar prescaler a 1024
    OUT     TCCR0B, R16

    RET
