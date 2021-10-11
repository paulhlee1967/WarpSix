 LST OFF
 DSK /HD1/WARP6/XFER/XYLOADER

* XYLOADER (XYmodem Loader)
* Public domain version 2.4.

* Instructions: assemble this file to save the XYLOADER
* module to disk.

* You can change the DSK pathname used to save the object
* code to whatever you desire.

BHIMEM = $BEFB
FREBUFR = $BEF8 ;free memory rtn
GETBUFR = $BEF5
ERROUT = $BE09
MEMSIZ = $73 ;current HIMEM, low/high

BEGIN = $8D00 ;we need up to $99FF

XMODEM = BEGIN-$300-$400-$2F00

   ;Xmodem needs $2F00 bytes

PAGES = BEGIN-$300-$400-XMODEM/$100

* Change these if XYGLOBALS changes!

EMPTY = $82 ;himem w/o Xmodem loaded
FULL = $53 ;himem with Xmodem loaded

INBUF = $200 ;line input buf
DOSCMD = $BE03 ;basic.system mli vector

 ORG $300

 JMP START

BHSAVE DFB 0
TEMP DFB 0
FLAG DFB 0

START LDA FLAG ;request flag
 BEQ RESERVE ;if zero, try to reserve
 JMP REMOVE ;if not, try to remove

* RESERVE: get space for XMODEM module and load it.

RESERVE LDA MEMSIZ+1
 CMP #EMPTY ;HIMEM without Xmodem loaded
 BEQ RES1 ;branch if correct
 LDA #11 ;invalid option
 JMP ERROUT

RES1 LDA BHIMEM ;get boot value of HIMEM
 STA BHSAVE ;save it
 LDA MEMSIZ+1 ;get current HIMEM
 STA TEMP ;save it

 LDA #PAGES ;allocate memory for XYMODEM
 JSR GETBUFR
 BNE ERROR

 LDA TEMP ;get saved HIMEM before call
 STA BHIMEM ;pretend it is boot HIMEM

LOAD LDX #0
LOAD1 LDA CALL1,X ;load it into memory
 STA INBUF,X
 BEQ LOAD2
 INX
 JMP LOAD1
LOAD2 JSR DOSCMD ;execute cmd through BI
 BCS ERROR
 CLC
 RTS

ERROR JMP ERROUT
CALL1 ASC "BLOAD XYMODEM",8D00

* REMOVE XYMODEM from memory, freeing it for BASIC

REMOVE LDA MEMSIZ+1 ;get HIMEM w/o Xmodem
 CMP #FULL ;is our module here?
 BEQ REM1 ;if so, remove it
 CLC  ;if not, do nothing.
 RTS

REM1 JSR FREBUFR
 LDA BHSAVE ;get saved BHIMEM
 STA BHIMEM ;restore original value
 CLC  ;clear carry for BASIC
 RTS
