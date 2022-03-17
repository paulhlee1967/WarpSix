 LST OFF

* Warp Six BBS Main
* Public domain version 2.6

* This file contains the first part of each modem
* driver. All modem drivers share the same structure:
* the Main module comes first, followed by the
* Standard module, then the hardware specific portion
* of the driver. By having the Main and Standard parts
* first, we can guarantee the location of all routines
* within these modules. In practice, we only use the
* vectors in Main and a couple of entry points at the
* beginning of the Standard module.

* These vectors exist to permit interdependencies
* between modules to be stable.

 LST ON
 DAT
OUTVEC CLD  ;Output vector, which must be
 JMP OUTPUT ;located on a page boundary.
OLDEXV JMP $FFFF ;set by Warp6.Loader

IRQV DS 2 ;location of P8 irq handler

DCDSTATE DS 1 ;must NOT be on zero page

PARSEV CLD  ;BI external cmd parser
 JMP PARSE ;for TYPE, SEND, RECEIVE,
   ;COPY and LS

* Routines that can be called from other modules

MOUTV JMP MOUT
MBUFCKV JMP MBUFCHK
MBUFINV JMP MBUFIN

* Routines that are called from BASIC

INIT2V JMP INIT2 ;M0. Set up modem
INITV JMP INIT1 ;M1. Set up flags/vars
GETCALLV JMP GETCALL ;M2. Wait for call/logon
GETLNV JMP GETLN ;M3. Main input call
LOGONV JMP LOGON ;M4. Save start connect time
GETTIMEV JMP GETTIME ;M5. Updates DATE & TIME
HANGUPV JMP HANGUPM ;M6. Hangs up/disables IRQ's
CLEARV JMP CLRMBUF ;M7. Clears modem buffer
REMOVEV JMP REMOVE ;M8. Disable IRQs/remove dvr

* These used/set from BASIC

RCODE DFB 0 ;RC return code. 0=ok
LOCALFLG DFB 0 ;LF local keybd active flag
REMFLG DFB 0 ;RF remote i/o active flag
BAUD DFB 3 ;BR baud rate (see table)
LEVEL DFB 0 ;LE security level 0-9
VIDW DFB 0 ;VI video width (0-255)
MODEFLG DFB 0 ;MD hidden mode enable flag
UCASEFLG DFB 0 ;UC convert input to upper
PSEFLAG DFB 0 ;PS ProTERM Special flag
FILESTOP DFB 0 ;FS filestop disable flag
SPLABORT DFB 0 ;SA spool was aborted flag
WWACTV DFB 0 ;indicates data in wrap buffer
   ;on re-entry to driver
NXTFLG DFB 0 ;NF/next bulletin flag
STARTMIN DFB 0 ;LM logon minute
STARTHR DFB 0 ;LH logon hour
MINELAP DFB 0 ;EM total mins connected
HOURELAP DFB 0 ;EH total hrs.
ENTFLG DFB 0 ;EF message entry actv flag

SLOT16 DFB 0 ;modem/interface slot offset

NUMCHAR DFB 0 ;number of chars in LINBUF

DEFBAUD DFB 3 ;2400 baud is default

 ;300 bps (1)
 ;1200 (2)
 ;2400 (3)
 ;4800 (4)
 ;9600 (5)
 ;19200 (6)
   ;38400 (7) (IIgs only)
   ;57600 (8) (IIgs only)

HOTFLG DFB $0 ;hot keys flag off=0

HOTECHO DFB $FF ;echo input if b7 set

SLOTM DFB 2 ;SM/slot modem/poke to change

BHSAVE DS 1 ;boot himem save location

PRIVATE DFB 0 ;private mode off/on flag
CHATFLG DFB 0 ;Chat flag on/off

TICS DFB 0 ;goes down modulo 256
STICS DFB 60 ;goes down modulo 60
SECONDS DFB 60 ;goes down modulo 60
SSECONDS DFB 0
MINUTES DFB 0
LASTVBL DFB $80
MBUFTAIL DFB 0 ;mbuf tail index
MBUFHEAD DFB 0 ;head index

* Timeout Counters

TIMEOUT DFB 4 ;timeout is 4 minutes

XTMOUT DFB 180 ;Pause on control-S for a
   ;maximum of 180 seconds.

OKCHECK DFB 30 ;30 seconds between OK checks

* MLI parameter lists accessed by other modules

OPARMS DFB 3 ;parm count
OPATH DW $0000 ;pathname ptr
 DA IOBUF ;file i/o buffer ptr
OREFNUM DS 1

CLPARMS DFB $01 ;parm count
CLREFNUM DFB $00 ;if zero, close all files.

RPARMS DFB 4 ;parm count
RREFNUM DS 1 ;refnum for our file
RBUFPTR DW $0000 ;bufr ptr
RREQCNT DFB $00 ;byte request count
 DFB $00 ;high byte 0
RXFRCNT DW $0000 ;xfer count

OPEN JSR MLI
 LST RTN
 DFB $C8
 DA OPARMS ;use our own parm list
 RTS

* Routines immediately accessable to other modules

 LST ON
CLOSE JSR MLI
 LST RTN
 DFB $CC ;close
 DA CLPARMS ;use our parm list
 RTS

 LST ON
GETTIME JSR MLI
 LST RTN
 DFB $82 ;Get_Time MLI call
 DW $0000
 RTS

* Delay # of tics in A. X and Y preserved.

 LST ON
DELAYTICS STA TICS
 LST RTN
:LOOP JSR CHKVBL
 LDA TICS
 BNE :LOOP
 RTS

* Delay for 1 second
* Preserves all registers.

 LST ON
DELAY1 PHA
 LST RTN
 LDA #60
 STA TICS
:LOOP JSR DELAYTICS
 PLA
 RTS

* Delay # of seconds in A. X and Y preserved.

 LST ON
DELAYSECS STA SECONDS
 LST RTN
 LDA #60
 STA STICS
:LOOP JSR CHKVBL
 LDA SECONDS
 BNE :LOOP
 RTS

* Check VBL to see if a tic occurred.
* Uses A register only.

 LST ON
CHKVBL LDA VBLINT
 LST RTN
 EOR LASTVBL
 BPL :NOTHING
 EOR LASTVBL
 STA LASTVBL
 BPL :NOTHING
:SKIP DEC TICS
 DEC STICS
 LDA STICS
 BEQ :SECOND ;branch when STICS zeroes
:NOTHING RTS
:SECOND DEC SECONDS ;dec seconds
 DEC SSECONDS
 BEQ :MINUTES
 LDA #60 ;and reset STICS
 STA STICS
 RTS
:MINUTES DEC MINUTES
 LDA #60
 STA SSECONDS
 STA STICS
 RTS

* PRINT routine. Call with JSR PRINT followed by
* ASCII text to be printed terminated by a 0 byte.
* May be high or low ASCII.

 LST ON
PRINT PLA  ;get low byte
 LST RTN
 INC A ;inc to point at data
 BNE :NOHI ;not zero, don't inc hi
:INCHI STA :PRTADR ;low byte is zero
 PLA  ;get high byte
 INC A
 STA :PRTADR+1 ;stuff it
 JMP :START
:NOHI STA :PRTADR ;save low byte
 PLA  ;get high byte
 STA :PRTADR+1 ;stuff it

:START LDA #$AD ;LDA absolute
 STA :PRLOOP ;save instruction

* Next three bytes are self-modifying

:PRLOOP DS 1 ;instruction
:PRTADR DS 2 ;two byte address

 BEQ :PRDONE ;exit on zero byte.
 ORA #%10000000 ;set high bit for COUT
 JSR COUT

 INC :PRTADR ;inc low byte of address
 BNE :PRLOOP ;if non-zero, continue
 INC :PRTADR+1 ;inc high byte of address
 BRA :PRLOOP ;continue

:PRDONE INC :PRTADR ;increment before
 BNE :PROUT ;exiting
 INC :PRTADR+1 ;inc high byte

:PROUT LDA #$4C ;JMP absolute
 STA :PRLOOP ;save instruction
 BRA :PRLOOP ;return to program

* MPRINT routine. Call with JSR MPRINT followed by
* ASCII text to be printed terminated by a 0 byte.
* May be high or low ASCII.

 LST ON
MPRINT PLA  ;get low byte
 LST RTN
 INC A ;inc to point at data
 BNE :NOHI ;not zero, don't inc hi
:INCHI STA :PRTADR ;low byte is zero
 PLA  ;get high byte
 INC A
 STA :PRTADR+1 ;stuff it
 JMP :START
:NOHI STA :PRTADR ;save low byte
 PLA  ;get high byte
 STA :PRTADR+1 ;stuff it

:START LDA #$AD ;LDA absolute
 STA :PRLOOP ;save instruction

* Next three bytes are self-modifying

:PRLOOP DS 1 ;instruction
:PRTADR DS 2 ;two byte address

 BEQ :PRDONE ;exit on zero byte.

 JSR MOUT
 LDA #2 ;inter-character delay
 JSR DELAYTICS

 INC :PRTADR ;inc low byte of address
 BNE :PRLOOP ;if non-zero, continue
 INC :PRTADR+1 ;inc high byte of address
 BRA :PRLOOP ;continue

:PRDONE INC :PRTADR ;increment before
 BNE :PROUT ;exiting
 INC :PRTADR+1 ;inc high byte

:PROUT LDA #$4C ;JMP absolute
 STA :PRLOOP ;save instruction
 BRA :PRLOOP ;return to program

* DCDLOST: set RCODE to 2, HANGUP, zero flags & RTS.
* Calls: HANGUP. Destroys all registers.

DCDLOST LDA #2 ;inform APPLESOFT
 STA RCODE
 BRA DCD3

DCD2 JSR HANGUP

 LST ON
DCD3 STZ LOCALFLG ;reset flags
 LST RTN
 STZ REMFLG
 CLC
 RTS

 LST ON
CURSORV JMP SHOWCUR
 LST RTN

 DS 1

* Data area for Ymodem

 LST ON
FIXNAME DFB 0
YCOUNT DFB 0
YTOTAL DFB 0
 LST RTN

* Xmodem data - 8 bytes

 LST ON
XERROR DFB 0 ;error code for BASIC
PFLAG DFB 0 ;ProDOS info xfer flag
TRYPRO DFB 0 ;try ProDOS xfer flag
CRCFLAG DFB 0 ;CRC yes/no flag
KFLAG DFB 0 ;1k option active flag
LFLAG DFB 0 ;4k option active flag
BINARY2 DFB 0 ;flag for Binary II xfer
YFLAG DFB 0 ;Ymodem yes/no flag (unused)

* Handle MLI Error by passing it to BASIC

MLIERR
 JSR BADCALL ;convert to BI error
 JSR UNLOAD
 JMP ERROUT ;exit to BI

* DS 17-8 ;NOT USED /phone number buffer
 LST RTN

* UPDATE: Calculate elapsed time

 LST ON
UPDATE JSR GETTIME ;get date/time from clock
 LST RTN
 LDA TIME ;minutes
 CMP STARTMIN
 BLT :LESSMIN ;if cur <, minelap=60-start+cur
 SEC  ;if cur >=, minelap=cur-start
 SBC STARTMIN
 STA MINELAP ;save result
 JMP :CALCHRS ;and exit.

:LESSMIN LDA #60
 SEC
 SBC STARTMIN
 CLC
 ADC TIME
 STA MINELAP ;save result & fall through

:CALCHRS LDA TIME+1 ;hours
 CMP STARTHR ;either < or >=.
 BLT :LESSHR ;current < starthr
 SEC  ;current is >= starthr
 SBC STARTHR ;hours elaps=cur-start
 STA HOURELAP ;store result
 LDA TIME ;get current minute
 CMP STARTMIN ;if <, subtract one hour
 BLT :DECHR
 RTS

:DECHR DEC HOURELAP
 RTS

:LESSHR LDA #24 ;24 hours in a day
 SEC
 SBC STARTHR ;hours elapsed =
 CLC  ;24-start+cur
 ADC TIME+1
 STA HOURELAP ;store result
 LDA TIME
 CMP STARTMIN ;if <, subtract one hour
 BLT :DECHR
:UPDEXIT RTS  ;exit.

 LST ON
ADJBPS DFB #$FF ;Adjust baud rate to match
   ;0=fixed, $FF=match speed
HSKFLAG DFB #$FF ;Handshaking active flag

LFFLAG DFB #$FF ;NOT USED /Send line feeds flag

UNLOAD JSR FREBUFR
 LST RTN
 LDA BHSAVE ;get saved BHIMEM
 STA BHIMEM ;restore original value
 CLC  ;clear carry for BASIC
 RTS

* GETEOF. Requires file refnum be stored in
* at EOFPARMS+1.

 LST ON
GETEOF LDA #2 ;set up parm list
 STA EOFPARMS ;parm count
 LDA #0
 STA EOFPARMS+2 ;low byte
 STA EOFPARMS+3 ;mid byte
 STA EOFPARMS+4 ;high byte

 JSR MLI
 DFB $D1 ;get_eof
 DA EOFPARMS ;point to location in buffer
 RTS ;return with any error

EOFPARMS DFB 2 ;parm count
EOFREF DS 1 ;file reference number
EOFLOW DS 1
EOFMID DS 1
EOFHI DS 1
 LST RTN
