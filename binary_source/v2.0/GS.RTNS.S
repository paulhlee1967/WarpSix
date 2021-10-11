* IIGS Z8530 Routines - High Speed Capable
* Public domain version 2.0

 XC ON
 XC ON

 LST ON
SERGET3 STAL $E10104 ;SerFlag
 LST RTN
 RTS
SERSAVE DS 1

* FIXFIRM: restore firmware interrupt handler

FIXFIRM LDA SERSAVE
 BRA SERGET3

* Ensure SERFLAG stays the way we set it.

REDO LDA SERSAVE
 ORA #%00000111 ;disable firmware IRQ handler
;for serial port B (Modem)
   ;%00111000 for serial port A
 BRA SERGET3

HSKON DFB %00100100
HSKOFF DFB %00000100

* Master interrupt handler

 LST ON
IRQMAST CLC  ;switch to native mode
 LST RTN
 XCE
 BCC QUICK ;was already in native mode
   ;so make a quick exit.
 XCE  ;emulation mode

 PHA  ;save A
 PHX  ;save X

 LDA GSCMDB ;our interrupt?
 LSR
 BCS RX

 PLX  ;if not, restore and exit.
 PLA

* JML to firmware's handler (and let it worry about
* this interrupt.)

 LST ON
QUICK JML $FFBC6C ;original mgr address
 LST RTN
 DS 1 ;do not use this byte
   ;(trashed by GS.LOADER)

IRQIN PHA  ;save A
 PHX  ;save X

RX LDA GSDATAB ;get character
 LDX MBUFTAIL ;tail index
 STA MBUF,X ;put at end of buf
 INC MBUFTAIL ;inc pointer

 LDA GSCMDB ;data pending?
 LSR  ;shift b0 into C
 BCS RX ;loop on data til done.

 PLX  ;restore X
 PLA  ;restore A
 RTI  ;return from interrupt


HANGUPM LDA RCODE ;check result code
 BEQ PRIGHTS ;normal logoff, do copyright
 CMP #3
 BEQ PRIGHTS ;local logoff, do copyright
 BNE HANGUP ;otherwise, no copyright

PRIGHTS JSR RIGHTS

HANGUP
 JSR DELAY1 ;wait 1 second

* Drop DTR

 PHP
 SEI
 LDA #%11101010
 LDX #5
 STX GSCMDB
 STA GSCMDB

 LDA #20 ;pause to allow DTR to take effect
 JSR DELAYTICS

* Raise DTR

 LDA #%01101010 ;DTR enabled 0=/HIGH, 8 data bits
 LDX #5 ;select wr5
 STX GSCMDB
 STA GSCMDB ;write it

 LDA #10
 JSR DELAYTICS
 PLP  ;restore status

 JSR MPRINT ;send Hayes escape code
 ASC '+++',00
 LDA #80
 JSR DELAYTICS ;pause just over 1 second
 JSR MPRINT ;send Hayes hangup command
 ASC 'ATH',0D00
 JSR DELAY1 ;wait for it to come to pass...
 JSR CLRMBUF ;clear buffer of result
 CLC
 RTS

* INIT1: init variables & flags, clear screen.
* send initialization string to modem.
* Calls: COUT
* Destroys all registers.

INIT1
 LDA SLOTM get real modem slot
 ASL A
 ASL A
 ASL A
 ASL A multiply by 16 for system use
 STA SLOT16
 STA UCASEFLG uppercase restrict on
 STA DCDSTATE default is no carrier
 STZ FILESTOP user can abort TYPE cmd
 STZ ENTFLG message entry not in progress
 STZ HOURELAP
 STZ MINELAP
 STZ HOURELAP
 STZ RCODE
 STZ LOCALFLG
 STZ REMFLG
 STZ CHATFLG
 STZ MODEFLG normal output mode
 STZ NUMCHAR
 STZ LEVEL
 STZ MBUFHEAD
 STZ MBUFTAIL
 STZ PRIVATE ;private output mode off
 STZ HOTFLG ;hotkeys off
 STZ WWCHAR
 STZ WWACTV
 STZ PSEFLAG

 JSR REDO ;ensure SERFLAG is set correctly

 LDA #<IRQIN ;ensure irq vector points to
 STA $3FE ;our routine!
 LDA #>IRQIN
 STA $3FF

 JSR HOME ;clear screen
 CLI
 CLC
 RTS

* INIT2: set up modem

INIT2 LDA DEFBAUD ;get default baud rate
 STA BAUD ;set the default baud rate
 JSR INITGS
 LDA #$FF
 STA :FLAG ;first time through
 JSR DELAY1

* Send Modem.Init file to modem

 LDA :MPATH1 ;set pointer to pathname
 STA OPATH
 LDA :MPATH1+1
 STA OPATH+1

 JSR OPEN
 BNE :ERR2

 LDA OREFNUM get refnum
 STA RREFNUM save for read
 STA CLREFNUM save for close

 LDA #<CBUF
 STA RBUFPTR
 LDA #>CBUF
 STA RBUFPTR+1
 LDA #1 one byte at a time
 STA RREQCNT
 STZ RREQCNT+1

:READ JSR MLI
 DFB #$CA read the Modem.Init file
 DA RPARMS
 BNE :CLOSE2 close on error

 LDA CBUF get char from file

 AND #%01111111 kill high bit
 CMP #$0D
 BNE :OUT
 PHA
 JSR CLRMBUF
 PLA

:OUT JSR MOUT

 CMP #$0D
 BEQ :GETOK

 LDA #2
 JSR DELAYTICS
 BRA :READ

:MPATH1 DA :MPATH
:MPATH STR 'MODEM.INIT'

:CLOSE2 PHA  save error code if any
 JSR CLOSE
 PLA  recover err code
 BEQ :OK
 CMP #$4C end of file encountered?
 BEQ :OK no, real error

:ERR2 JMP ERROUT let BI handle unexpected error

:GETOK BIT :FLAG
 BPL :GETOK1
 STZ :FLAG
 LDA #80
 JSR DELAYTICS pause after 1st line
 BRA :READ and continue...

:GETOK1 LDA #3 time out in 3 seconds
 JSR GETRESULT
 BCS :NORES
 LDA RESBUF
 CMP #'0'
 BNE :RING
:BETWIXT LDA #20
 JSR DELAYTICS
 BRA :READ
:RING CMP #'2'
 BEQ :BETWIXT

:NORES JSR HANGUP
 JSR CLOSE
 LDA #3 device not connected
 BNE :ERR2 always
:OK
 JSR HOME
 RTS
:FLAG DS 1

* CALLCHK: see if call coming in. C=0 means yes, C=1 no.
* Calls: MBUFCHK, MBUFIN, PRINT. Destroys all registers.

CALLCHK JSR MBUFCHK data from modem?
 BEQ NORING no, continue
 JSR MBUFIN get modem character
 AND #%01111111 kill high bit
 CMP #'2' ring result code?
 BNE NORING
 JSR PRINT
 HEX 8D
 ASC "Ring.",8D8D00
 CLC  clear means ring
 RTS
NORING SEC  set means no ring
 RTS

* GETCALL: await call, local logon, or quit command.
* Returns to Basic with REMFLG or LOCALFLG on, or
* does a JSR REMOVE and a JMP QUIT.
* Destroys all registers.

GETCALL
 LDA OKCHECK ;number of seconds between
 STA SECONDS ;modem checks.
 LDA #60
 STA STICS
:CALL2 JSR CHKVBL
 LDA SECONDS
 BEQ :MCHECK
:CALL3 LDA KEYBD
 BPL :MODEM no
 STA STROBE kill strobe for next time
 BIT OAKEY
 BPL :MODEM
 JSR UPSHIFT
 CMP #"L" logon command? (L)
 BNE :QCMD no, check for quit cmd
 LDA #$FF enable local keybd
 STA LOCALFLG do it
 STZ PSEFLAG
 RTS
:QCMD CMP #"Q" quit cmd? (Q)
 BNE :MODEM
 JSR REMOVE
 JMP QUIT
:MODEM JSR CALLCHK call coming in?
 BCS :CALL2 no
 JSR ANSWER answer routine
 BEQ :NOCARR 0=no carrier
 STA BAUD save baud rate
 BIT ADJBPS adjust bps rate?
 BPL :NEXT flag off; stay fixed.
 JSR DOBAUD adjust our baud rate
:NEXT LDA #$FF turn on REMFLG (caller online)
 STA REMFLG
 BRA :PSEID check for ProTERM Special
:NOCARR
 JSR HANGUP
 JSR INIT1
 JSR INIT2
 BRA GETCALL
:NORES JSR INIT2
 LDA #3 no device connected error
 JMP ERROUT

* :MCHECK: Send AT command to modem to make sure it
* is still online and waiting for a call.

:MCHECK JSR MPRINT
 ASC 'AT',0D00
 JSR GETOK
 BCS :NORES
 RTS  ;return to BASIC

* Check if user has ProTERM Special Emulation

:PSEID
 LDA #30
 JSR DELAYTICS
 LDA #$05 Control-E (enquire)
 JSR MOUT
 LDA #30
 STA TICS

* Loop for 40 tics, looking for ESC character

:WAIT JSR CHKVBL
 LDA TICS
 BEQ :NO
 JSR MBUFCHK
 BEQ :WAIT
 JSR MBUFIN
 CMP #$1D
 BNE :WAIT
 LDA #$FF using ProTERM special
 STA PSEFLAG
 CLC
 RTS
:NO STZ PSEFLAG
 JSR CLRMBUF
 CLC
 RTS

* Get result from modem or timeout.
* Carry clear if result obtained; set if not.
* Enter with # of seconds to timeout in A.

GETRESULT
 STA SECONDS
 LDA #60
 STA STICS
 STZ RESBUF ;zero out buffer
 STZ RESBUF+1
 STZ :INDEX

:OK1 JSR CHKVBL
 LDA SECONDS
 BEQ :FAILURE

:LOOP JSR MBUFCHK wait for result code
 BEQ :OK1
 JSR MBUFIN
 AND #%01111111 kill high bit

 CMP #$0D ;cr?
 BNE :CHECK
 LDY :INDEX
 CPY #0
 BEQ :LOOP ;ignore CR if 1st character!
 BNE :TEST ;got final cr; go test

:CHECK CMP #$20
 BLT :LOOP ;ignore control characters

 LDY :INDEX
 STA RESBUF,Y ;save char in the buffer!
 INC :INDEX ;increment pointer
 LDY :INDEX
 CPY #2
 BLT :LOOP ;maximum 2 characters
:TEST CLC
 RTS
:FAILURE SEC
 RTS

:INDEX DS 1

* ANSWER: issues ATA command to modem & awaits result
* code. Returns with BAUD index in A. A=0 means no
* carrier or bad result.

ANSWER LDA #50
 JSR DELAYTICS

* JSR PRINT print to screen
* ASC "Answering...",8D8D00

 JSR CLRMBUF
 JSR MPRINT print to modem
 ASC 'ATA',0D00 answer cmd

CONNECT LDA #40
 JSR GETRESULT
 BCS :NOCARR

:TEST LDA RESBUF get 1st character
 CMP #'3' no carrier?
 BEQ :NOCARR
 CMP #'5'
 BEQ :CON1200
 CMP #'1'
 BEQ :TEST2
* CMP #'2'
* BEQ :CON38400
:NOCARR LDA #0 no carrier
 RTS

:TEST2 LDA RESBUF+1
 BEQ :CON300
 CMP #'0'
 BEQ :CON2400
 CMP #'1'
 BEQ :CON4800
 CMP #'2'
 BEQ :CON9600
 CMP #'4'
 BEQ :CON19200
 CMP #'6'
 BEQ :CON19200
 BNE :NOCARR

:CON300 LDA #1
 RTS
:CON1200 LDA #2 CONNECT 1200
 RTS
:CON2400 LDA #3 CONNECT 2400
 RTS
:CON4800 LDA #4 CONNECT 4800
 RTS
:CON9600 LDA #5 CONNECT 9600
 RTS
:CON19200 LDA #6 CONNECT 19200
 RTS
*:CON38400 LDA #7 CONNECT 38400
* RTS

RESBUF DS 2 buffer for result codes

* GETOK: get OK result code (0) from modem or timeout.
* On return, carry clear if successful, set if not.

GETOK LDA #1
 JSR GETRESULT
 BCS :FAILURE
:TEST LDA RESBUF
 CMP #'0' ;ok?
 BEQ :SUCCESS
 CMP #'2' ;ring?
 BEQ :SUCCESS
 JSR DELAY1
 JSR CLRMBUF
:FAILURE SEC
 RTS

:SUCCESS LDA #30
 JSR DELAYTICS
 JSR CLRMBUF
 CLC
 RTS

REMOVE SEI
 JSR DISABLE ;disable modem port
 JSR FIXFIRM ;reset SerFlag

 LDA IRQV
 STA $3FE
 LDA IRQV+1
 STA $3FF

 CLC
 XCE
 REP #$30 ;full 16-bit mode

 PEA $0004 ;Interrupt Manager refnum
 LDA QUICK+3
 PHA
 LDA QUICK+1 ;original manager address
 PHA

 LDX #$1003 ;SetVector
 JSL $E10000

 SEC  ;emulation mode
 XCE
 SEP #$30
 MX %11

 CLI
 RTS

QUIT JSR MLI
 DFB $65 ;Quit call
 DA :QPARMS

:QPARMS DFB 4
 DFB 0
 DW $0000
 DFB 0
 DW $0000

* INITGS: initialize the Modem Port
* (Channel B is modem port, A is printer port)

INITGS SEI

 BIT HSKFLAG
 BPL :OFF
 LDA HSKON
 BRA :SET
:OFF LDA HSKOFF
:SET STA MTST1+1
 STA MTST2+1

 BIT GSCMDB ;hit rr0 once to sync up

 LDX #9 ;wr9
 LDA #RESETCHB ;load constant to reset Ch B
   ;for Ch A, use RESETCHA
 STX GSCMDB
 STA GSCMDB

 BIT GSCMDB ;SCC needs 11 pclck to recover
 BIT GSCMDB

 LDX #4 ;wr4
 LDA #%01000100 ;X16 clock mode,
 STX GSCMDB ;1 stop bit, no parity
 STA GSCMDB ;could be 1.5 or 2 stop bits
   ;1.5 set bits 3,2 to 1,0
   ;2   set bits 3,2 to 1,1
 LDX #3 ;wr3
 LDA #%11000001 ;8 data bits, receiver enabled
 STX GSCMDB ;could be 7 or 6 or 5 data bits
 STA GSCMDB ;for 8 bits, bits 7,6 = 1,1
 ;for 7 bits, bits 7,6 = 0,1
   ;for 6 bits, bits 7,6 = 1,0
   ;for 5 bits, bits 7,6 = 0,0

 LDX #5 ;wr5
 LDA #%01101010 ;DTR enabled 0=/HIGH, 8 data bits
 STX GSCMDB ;no BRK, xmit enabled, no SDLC
 STA GSCMDB ;RTS *MUST* be disabled, no crc

 JSR DOBAUD

 LDX #11 ;wr11
 LDA #WR11B ;load constant to write
 STX GSCMDB
 STA GSCMDB

 LDA #%00000001 ;enable baud rate gen
 LDX #14 ;wr14
 STX GSCMDB
 STA GSCMDB ;write value

* Enable Interrupts

 LDX #15 ;wr15
 STX GSCMDB
 STZ GSCMDB

 LDA #%00010000 ;reset ext. stat. ints.
 STZ GSCMDB
 STA GSCMDB

 STZ GSCMDB ;twice
 STA GSCMDB

 LDX #1 ;wr1
 LDA #%00010000 ;Wait Request disabled
 STX GSCMDB ;allow IRQs on Rx only
 STA GSCMDB ;No transmit interrupts (b1)

 CLI
 RTS  ;we're done!

* DISABLE: ensure serial port IRQ's turned off
* (DTR unaffected; use HANGUP or GSDTR)

DISABLE PHP
 SEI

* Interrupt Status

 LDX #1 ;wr1
 STX GSCMDB
 STZ GSCMDB ;no DMA, no interrupts
 LDA GSDATAB ;eat any character waiting

 PLP
 RTS


DOBAUD PHP
 SEI

 LDY BAUD ;check user's value
 CPY #6+1 ;outside legal range?
 BGE :BAD
 CPY #0 ;zero?
 BNE :GOOD
:BAD LDY #6 ;force to 19200 if bad

:GOOD

*:GOOD LDA #0 ;disable BRG (stop clock)
* LDX #14 ;wr14
* STX GSCMDB
* STA GSCMDB ;write it

 LDA #12
 STA GSCMDB
 LDA BAUDL-1,Y ;load time constant low
 STA GSCMDB

 LDA #13
 STA GSCMDB
 LDA BAUDH-1,Y ;load time constant high
 STA GSCMDB

* LDA #%00000001 ;re-enable BRG
* LDX #14
* STX GSCMDB
* STA GSCMDB

:EXIT PLP
 RTS

BAUDL DFB 126 ;300 bps (1)
 DFB 94 ;1200 (2)
 DFB 46 ;2400 (3)
 DFB 22 ;4800 (4)
 DFB 10 ;9600 (5)
 DFB 4 ;19200 (6)
* DFB 1 ;38400 (7)
* DFB 0 ;57600 (8)

BAUDH DFB 1 ;300 bps (1)
 DFB 0 ;1200 (2)
 DFB 0 ;2400 (3)
 DFB 0 ;4800 (4)
 DFB 0 ;9600 (5)
 DFB 0 ;19200 (6)
* DFB 0 ;38400 (7)
* DFB 0 ;57600 (8)

* MOUT: send character in A to modem, regardless of
* carrier state. Preserves all registers.

MOUT PHA

MWAIT LDA GSCMDB ;rr0

* Bit 2 on means Tx empty
* Bit 5 reflects the unlatched state of the /cts pin.
* If bit 5 is 1, handshake is present
* If bit 5 is 0, handshake is absent

MTST1 AND #%00100100 ;bit 2 on means ready to send
MTST2 CMP #%00100100 ;bit 5 on means cts present
 BNE MWAIT

:READY PLA  ;get char to send
 STA GSDATAB ;send the character
 RTS

* MBUFCHK: see if data ready in MBUF.
* BEQ for no data, BNE for data.

MBUFCHK SEI

 PHA
 LDA GSCMDB
 AND #%00001000 ;get DCD/GPi bit
 EOR #%00001000 ;flip the DCD/GPi bit
 STA DCDSTATE ;non-zero means offline
 PLA

 LDX MBUFTAIL get tail index
 CPX MBUFHEAD compare to head index
 CLI  if different, data is
 RTS  ready.

* CLRMBUF: clear mbuf.

CLRMBUF SEI
 STZ MBUFHEAD
 STZ MBUFTAIL
 LDA GSDATAB ensure no data in SCC
 LDA GSDATAB
 LDA GSDATAB
:EXIT CLI
 RTS

* MBUFIN: get a byte from mbuf.

MBUFIN SEI
 LDX MBUFHEAD get head index
 LDA MBUF,X get byte from head
 INC MBUFHEAD inc head index
 CLI
 RTS

* Dial routine

DIAL JSR DELAY1 1 second pause
 JSR MPRINT dial
 ASC 'ATD',00
 BIT TONE
 BPL :PULSE
 LDA #'T'
 JSR MOUT
 BRA DIALIT
:PULSE LDA #'P'
 JSR MOUTV

* Dial phone number POKEd into NUMBER buffer

DIALIT LDY #0
:LOOP LDA NUMBER,Y
 BEQ :DOCR
 JSR MOUT
 INY
 BRA :LOOP
:DOCR LDA #$0D
 JSR MOUT
 JSR CLRMBUF
 JSR CONNECT

* Determine if we are connected

 BEQ :NOCARR 0=no carrier
 STA BAUD save baud rate
 BIT ADJBPS
 BPL :NEXT
 JSR DOBAUD adjust our baud rate
:NEXT LDA #$FF turn on REMFLG (caller online)
 STA REMFLG
 JSR DELAY1 pause a bit
 CLC
 RTS  and back we go.

:NOCARR SEC
 RTS
 FIN
