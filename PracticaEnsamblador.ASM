; This is a basic template file for writing 48K Spectrum code.

AppFilename             equ "PracticaEnsamblador"       ; What we're called (for file generation)

AppFirst                equ $8000                       ; First byte of code (uncontended memory)

                        zeusemulate "48K","ULA+"        ; Set the model and enable ULA+


; Start planting code here. (When generating a tape file we start saving from here)

                        org AppFirst                    ; Start of application

AppEntry                CALL PantallaInicio             ;
Restart                 CALL ImprimirPalas              ;
                        CALL IniciarPelota              ;
Loop                    CALL MoverPelota                ;
                        CALL MovimientoPalas            ;
                        halt                            ;
                        jp Loop                         ; Replace these lines with your code

; --------------------------------------------------------------------------------------------

PantallaInicio          call CHANOPEN                   ;
                        ld de,lineaSuperior             ;
                        ld bc,32                        ; Rellenamos linea superior
                        call PRINT                      ;

                        ld de,PuntosIzq                 ;
                        ld bc,4                         ;
                        call PRINT                      ;

                        ld de,PuntosDer                 ;
                        ld bc,4                         ;
                        call PRINT                      ;

                        ld de,lineaInferior             ; Rellenamos linea inferior
                        ld bc,34                        ;
                        call PRINT                      ;
                        ld de,pedirEspacio              ; Pedimos que se pulse el espacio
                        ld bc,46                        ;
                        call PRINT                      ;

Bucle                   LD bc, $7FFE                    ; Mientras el espacio no se pulse no saldra del bucle
                        IN a,(C)                        ;
                        AND %01                         ;
                        JR NZ,Bucle                     ;
                        ld de,vacio                     ; La variable vacio quita la frase que pide el espacio cuando este se pulse
                        ld bc,46                        ;
                        call PRINT                      ;
                        RET                             ;

; -------------------------------------------------------------------------------
; Imprime las palas y ejecuta su rutina de movimiento
ImprimirPalas           ld de,PalaIzq                   ;
                        ld bc,4                         ;
                        call PRINT                      ;

                        ld de,PalaDer                   ;
                        ld bc,4                         ;
                        call PRINT                      ;

                        ld de,CabezaIzq                 ;
                        ld bc,4                         ;
                        call PRINT                      ;

                        ld de,CabezaDer                 ;
                        ld bc,4                         ;
                        call PRINT                      ;
                        RET                             ;

; ------------------------------------------------------------------------------
; Rutina para iniciar aleatoriamente la direccion de la pelota


IniciarPelota           LD A, 10                        ; Colocar Pelota en su sitio
                        LD (Pelota+1), A                ;
                        LD A, 16                        ;
                        LD (Pelota+2), A                ;

                        LD DE, Pelota                   ; Imprime Pelota
                        LD BC, 4                        ;
                        CALL PRINT                      ;

                        CALL RandomBit                  ; Elige dir random en EjeX
                        JR C, TrueEjeX                  ;
                        LD A, -1                        ;

IniciarPelota2          LD (DirEjeX), A                 ;
                        CALL RandomBit                  ; Elige dir random en EjeY
                        JR C, TrueEjeY                  ;
                        LD A, -1                        ;
IniciarPelotaFin        LD (DirEjeY),A                  ;
                        RET                             ;


TrueEjeX                LD A, 1                         ;
                        JP IniciarPelota2               ;

TrueEjeY                LD A, 1                         ;
                        JP IniciarPelotaFin             ;
; ----------------------------------------------------------------------
; Rutina de movimiento de la pelota

MoverPelota             LD A, (Pelota+1)                ; EjeX
                        LD (BorrarPelota+1), A          ;
                        LD HL, (DirEjeX)                ;
                        ADD L                           ;
                        CP 1                            ; Si LLega al borde de arriba rebota
                        JR Z, RebotarArriba             ;
                        CP 21                           ; Si LLega al borde de abajo rebota
                        JR Z, RebotarAbajo              ;
                        LD (Pelota+1), A                ;

                        LD A, (Pelota+2)                ; EjeY
                        LD (BorrarPelota+2), A          ;
                        LD HL, (DirEjeY)                ;
                        ADD L                           ;
                        CP 0                            ;
                        JR Z, BordeIzq                  ;
                        CP 32                           ;
                        JR Z, BordeDer                  ;
                        LD (Pelota+2), A                ;

                        LD DE, Pelota                   ; Imprime Pelota
                        LD BC, 4                        ;
                        CALL PRINT                      ;

                        LD DE, BorrarPelota             ; Borra Pelota
                        LD BC, 4                        ;
                        CALL PRINT                      ;
                        RET                             ;

RebotarArriba           LD A, 1                         ; Cambia la direccion hacia abajo, y vuelve a llamar a mover pelota
                        LD (DirEjeX), A                 ;
                        JP MoverPelota                  ;

RebotarAbajo            LD A, -1                        ; Cambia la direccion hacia arriba, y vuelve a llamar a mover pelota
                        LD (DirEjeX), A                 ;
                        JP MoverPelota                  ;


BordeIzq                LD A, (PalaIzq+1)               ; Miramos que haya tocado el palo izquierda
                        LD HL, (Pelota+1)               ;
                        CP L                            ;
                        JR Z, RebotarPaloIzq            ;
                        LD A, (CabezaIzq+1)             ; Miramos que haya tocado la cabeza izquierda
                        CP L                            ;
                        JR Z, RebotarCabezaIzq          ;
                        CALL SumarPuntoDer              ;
                        JP MoverPelota                  ;

BordeDer                LD A, (PalaDer+1)               ; Miramos que haya tocado el palo izquierda
                        LD HL, (Pelota+1)               ;
                        CP L                            ;
                        JR Z, RebotarPaloDer            ;
                        LD A, (CabezaDer+1)             ; Miramos que haya tocado la cabeza izquierda
                        CP L                            ;
                        JR Z, RebotarCabezaDer          ;
                        CALL SumarPuntoIzq              ;
                        JP MoverPelota                  ;


RebotarPaloIzq          LD A, 1                         ;
                        LD (DirEjeX), A                 ;
                        LD (DirEjeY), A                 ; Hace que rebote hacia abajo derecha
                        JP MoverPelota                  ;

RebotarCabezaIzq        LD A, -1                        ;
                        LD (DirEjeX), A                 ;
                        LD A, 1                         ;
                        LD (DirEjeY), A                 ; Hace que rebote hacia arriba derecha
                        JP MoverPelota                  ;

RebotarPaloDer          LD A, 1                         ;
                        LD (DirEjeX), A                 ;
                        LD A, -1                        ;
                        LD (DirEjeY), A                 ; Hace que rebote hacia abajo izquierda
                        JP MoverPelota                  ;

RebotarCabezaDer        LD A, -1                        ;
                        LD (DirEjeX), A                 ;
                        LD (DirEjeY), A                 ; Hace que rebote hacia arriba izquierda
                        JP MoverPelota                  ;
; ----------------------------------------------------------------------
; Rutinas de movimiento de las palas


MovimientoPalas         ld bc,$FEFE                     ;
                        in a,(c)                        ;
                        rra                             ;
                        rra                             ; b1 '1'
                        push af                         ;
                        call nc,MoverArribaPalaIzq      ;
                        pop af                          ;
                        rra                             ; b2 '2'
                        push af                         ;
                        call nc,MoverAbajoPalaIzq       ;
                        pop af                          ;
                        rra                             ; b3 '3'
                        push af                         ;
                        call nc,MoverArribaPalaDer      ;
                        pop af                          ;
                        rra                             ; b4 '4'
                        push af                         ;
                        call nc,MoverAbajoPalaDer       ;
                        pop af                          ;
                        CALL Delay                      ;
                        ret                             ;

SaltoAbajoPalaDer       jp MoverAbajoPalaDer            ; salto a la ultima label ya que el JR no llega

MoverArribaPalaIzq      ld a,(CabezaIzq+1)              ; mover pala izquierda arriba
                        DEC A                           ;
                        CP 1                            ;
                        JR Z, volver1                   ; si esta en el borde se sale de la rutina
                        ld (CabezaIzq+1),a              ;
                        ld de,CabezaIzq                 ;
                        ld bc,4                         ;
                        call PRINT                      ; muevo cabeza
                        ld a,(PalaIzq+1)                ;
                        ld (borrarPalaIzq+1),a          ;
                        ld de,borrarPalaIzq             ;
                        ld bc,4                         ;
                        call PRINT                      ; borro
                        ld a,(PalaIzq+1)                ;
                        DEC A                           ;
                        ld (PalaIzq+1),A                ;
                        ld de,PalaIzq                   ;
                        ld bc,4                         ;
                        call PRINT                      ; muevo palo

volver1                 RET                             ;

MoverAbajoPalaIzq       ld a,(PalaIzq+1)                ;
                        INC A                           ;
                        cp 21                           ;
                        JR Z,Volver2                    ; si esta en el borde se sale de la rutina
                        ld (PalaIzq+1),A                ;
                        ld de,PalaIzq                   ;
                        ld bc,4                         ;
                        call PRINT                      ;
                        ld a,(CabezaIzq+1)              ; mover pala izquierda abajo
                        ld (borrarPalaIzq+1),a          ;
                        INC A                           ;
                        ld (CabezaIzq+1),a              ;
                        ld de,CabezaIzq                 ;
                        ld bc,4                         ;
                        call PRINT                      ; muevo cabeza
                        ld de,borrarPalaIzq             ;
                        ld bc,4                         ;
                        call PRINT                      ; borro

Volver2                 RET                             ;

MoverArribaPalaDer      ld a,(CabezaDer+1)              ; mover pala derecha arriba
                        DEC A                           ;
                        CP 1                            ;
                        JR Z, volver3                   ; si esta en el borde se sale de la rutina
                        ld (CabezaDer+1),a              ;
                        ld de,CabezaDer                 ;
                        ld bc,4                         ;
                        call PRINT                      ; muevo cabeza
                        ld a,(PalaDer+1)                ;
                        ld (borrarPalaDer+1),a          ;
                        ld de,borrarPalaDer             ;
                        ld bc,4                         ;
                        call PRINT                      ; borro
                        ld a,(PalaDer+1)                ;
                        DEC A                           ;
                        ld (PalaDer+1),A                ;
                        ld de,PalaDer                   ;
                        ld bc,4                         ;
                        call PRINT                      ; muevo palo

volver3                 RET                             ;


MoverAbajoPalaDer       ld a,(PalaDer+1)                ;
                        INC A                           ;
                        cp 21                           ;
                        JR Z,Volver2                    ; si esta en el borde se sale de la rutina
                        ld (PalaDer+1),A                ;
                        ld de,PalaDer                   ;
                        ld bc,4                         ;
                        call PRINT                      ;
                        ld a,(CabezaDer+1)              ; mover pala izquierda abajo
                        ld (borrarPalaDer+1),a          ;
                        INC A                           ;
                        ld (CabezaDer+1),a              ;
                        ld de,CabezaDer                 ;
                        ld bc,4                         ;
                        call PRINT                      ; muevo cabeza
                        ld de,borrarPalaDer             ;
                        ld bc,4                         ;
                        call PRINT                      ; borro

Volver4                 RET                             ;

; ---------------------------------------------------------------------------------------------
; rutina para añadir 1 punto
SumarPuntoIzq           LD A, (PuntosIzq+3)             ;
                        INC A                           ;
                        CP '2'                          ;
                        JR Z, Resetear                  ; Si ha llegado al max, resetea el programa
                        LD (PuntosIzq+3), A             ; Sino sigue normalmente e imprime
                        ld de,PuntosIzq                 ;
                        ld bc,4                         ;
                        call PRINT                      ;
                        LD A, -1                        ;
                        LD (DirEjeY), A                 ;
                        CALL SacarPelota                ;
                        RET                             ;

SumarPuntoDer           LD A, (PuntosDer+3)             ;
                        INC A                           ;
                        CP '2'                          ;
                        JR Z, Resetear                  ; Si ha llegado al max, resetea el programa
                        LD (PuntosDer+3), A             ; Sino sigue normalmente e imprime
                        ld de,PuntosDer                 ;
                        ld bc,4                         ;
                        CALL PRINT                      ;
                        LD A, 1                         ;
                        LD (DirEjeY), A                 ;
                        CALL SacarPelota                ;
                        RET                             ;

; ---------------------------------------------------------------------------------------------
; Sacar Pelota

SacarPelota             LD A, 10                        ; Colocar Pelota en su sitio
                        LD (Pelota+1), A                ;
                        LD A, 16                        ;
                        LD (Pelota+2), A                ;

                        LD DE, Pelota                   ; Imprime Pelota
                        LD BC, 4                        ;
                        CALL PRINT                      ;
                        RET                             ;


; ---------------------------------------------------------------------------------------------
; rutina para resetear
Resetear                ld A, (CabezaIzq+1)               ; borrar pala izquierda
                        ld (borrarPalaIzq+1), A         ;
                        ld de,borrarPalaIzq             ;
                        ld bc,4                         ;
                        call PRINT                      ;
                        ld A, (CabezaIzq+1)               ;
                        INC A                           ;
                        ld (borrarPalaIzq+1), A         ;
                        ld de,borrarPalaIzq             ;
                        ld bc,4                         ;
                        call PRINT                      ;


                        ld A, (CabezaDer+1)               ; borrar pala derecha
                        ld (borrarPalaDer+1), A         ;
                        ld de,borrarPalaDer             ;
                        ld bc,4                         ;
                        call PRINT                      ;
                        ld A, (CabezaDer+1)             ;
                        INC A                           ;
                        ld (borrarPalaDer+1), A         ;
                        ld de,borrarPalaDer             ;
                        ld bc,4                         ;
                        call PRINT                      ;

                        LD DE, GameOver                 ; Imprime Game Over
                        LD BC, 61                       ;
                        CALL PRINT                      ;

                        LD A, 48                        ; NO FUCA POR AQUI-----------------------///%577444444345yhndhnghhg
                        LD (PuntosIzq+3), A             ;
                        LD (PuntosDer+3), A             ;
                        ld de,PuntosIzq                 ;
                        ld bc,4                         ;
                        CALL PRINT                      ;
                        ld de,PuntosDer                 ; Cambia e imprime los puntos a 0 otra vez de ambos jugadores
                        ld bc,4                         ;
                        CALL PRINT                      ;

                        CALL Bucle                      ;
                        JP Restart                      ;
; ---------------------------------------------------------------------------------------------

; ---------------------------------------------------------------------------------------------
RandomBit               LD A,R                          ;
                        RRA                             ;
                        RET                             ;


Delay:                  push bc                         ;
                        ld b,5                          ;
Espera                  HALT                            ;
                        DJNZ Espera                     ;
                        POP BC                          ;
                        RET                             ;

CHANOPEN                equ 5633                        ;
PRINT                   equ 8252                        ;


lineaSuperior           defb 22,1,2,"_____________________________";
lineaInferior           defb 22,21,1,"-------------------------------";
pedirEspacio            defb 22,10,1,"PULSE LA BARRA ESPACIADORA PARA COMENZAR...";
vacio                   defb 22,10,1,"                                           ";

PalaIzq                 defb 22,11,1,"|"                ;
CabezaIzq               defb 22,10,1,"0"                ;
PalaDer                 defb 22,11,31,"|"               ;
CabezaDer               defb 22,10,31,"0"               ;

borrarPalaIzq           defb 22,1,1, " "                ;
borrarPalaDer           defb 22,1,31, " "               ;

BorrarPelota            defb 22,10,16, " "              ;
Pelota                  defb 22,10,16, "o"              ;

DirEjeX                 defb 0                          ;
DirEjeY                 defb 0                          ;

PuntosIzq               defb 22,1,1,"0"                 ;
PuntosDer               defb 22,1,31,"0"                ;

GameOver                defb 22,10, 1, "GAME OVER. PULSE ESPACIO PARA            VOLVER A JUGAR..." ;

; ;;;Usamos el registro H para la direccion horizontal L para la direccion vertical

; Stop planting code after this. (When generating a tape file we save bytes below here)
AppLast                 equ *-1                         ; The last used byte's address

; Generate some useful debugging commands

                        profile AppFirst,AppLast-AppFirst+1 ; Enable profiling for all the code

; Setup the emulation registers, so Zeus can emulate this code correctly

Zeus_PC                 equ AppEntry                    ; Tell the emulator where to start
Zeus_SP                 equ $FF40                       ; Tell the emulator where to put the stack

; These generate some output files

                        ; Generate a SZX file
                        output_szx AppFilename+".szx",$0000,AppEntry ; The szx file

                        ; If we want a fancy loader we need to load a loading screen
;                        import_bin AppFilename+".scr",$4000            ; Load a loading screen

                        ; Now, also generate a tzx file using the loader
                        output_tzx AppFilename+".tzx",AppFilename,"",AppFirst,AppLast-AppFirst,1,AppEntry ; A tzx file using the loader


