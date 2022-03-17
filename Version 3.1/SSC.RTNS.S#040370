* Warp Six SSC Routines

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
 LDA #$FF
 STA UCASEFLG uppercase restrict on
 STA DCDSTATE default is no carrier
 STA HOTECHO echo hot keys

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

 LDA #<IRQIN ;ensure irq vector points to
 STA $3FE ;our routine!
 LDA #>IRQIN
 STA $3FF

 JSR HOME ;clear screen
 RTS

* INIT2: set up modem

INIT2 LDA DEFBAUD ;get default baud rate
 STA BAUD ;set the default baud rate
* JSR INITSSC
* JSR HANGUP
 JSR INITSSC

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
 LDA #120
 JSR DELAYTICS after first line, pause
 BRA :READ and continue...

:GETOK1 LDA #3 time out in 3 seconds
 JSR GETRESULT
 BCS :NORES
 LDA RESBUF
 CMP #'0'
 BNE :RING
:BETWIXT LDA #30
 JSR DELAYTICS
 BRA :READ
:RING CMP #'2'
 BEQ :BETWIXT

:NORES JSR CLOSE
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
 CLC
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
:NEXT
 LST ON
 LDA #30
 LST RTN
 JSR DELAYTICS
 JSR CLRMBUF
 STZ NUMCHAR
 LDA #$FF turn on REMFLG (caller online)
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

:PSEID LDA #30
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
 CLC
 RTS

* Get result from modem or timeout.
* Carry clear if result obtained; set if not.
* Enter with # of seconds to timeout in A.

GETRESULT
 STA SECONDS
 LDA #60
 STA STICS
 LDA #' '
 STA RESBUF ;zero out buffer
 STA RESBUF+1
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

 JSR PRINT print to screen
 ASC "Answering...",8D8D00

 JSR CLRMBUF
 JSR MPRINT print to modem
 ASC 'ATA',0D00 answer cmd

CONNECT LDA #45
 JSR GETRESULT
 BCS :NOCAR

 LDY #0 ;index into results table
 LDX #0 ;index into codes table

:TEST1 LDA RESBUF ;check 1st char of result
 CMP :RESULTS,Y
 BEQ :TEST2

:MISS1 INY  ;skip over 2nd char
:MISS2 INY  ;looking at next result
 INX  ;next code.
 CPX #8 ;past end of table?
 BGE :NOCAR ;bad result.
 BRA :TEST1 ;continue testing.

:TEST2 INY  ;compare 2nd in table
 LDA RESBUF+1 ;with 2nd char of result
 CMP :RESULTS,Y
 BNE :MISS2 ;no match this time.
 LDA :CODES,X
 RTS
:NOCAR LDA #0
 RTS

:RESULTS ASC '3 ' ;0  = NO CARRIER
 ASC '1 ' ;1  = 300
 ASC '5 ' ;5  = 1200
 ASC '10' ;10 = 2400
 ASC '11' ;11 = 4800
 ASC '12' ;12 = 9600
 ASC '14' ;14 = 19200
 ASC '16' ;16 = 19200

:CODES HEX 00,01,02,03,04,05,06,06

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
:FAILURE SEC
 RTS

:SUCCESS LDA #30
 JSR DELAYTICS
 JSR CLRMBUF
 CLC
 RTS

* Disable interrupt source

REMOVE SEI
 LDY SLOT16
 LDA #%00000010 ;no irq's
 STA CMDREG,Y
 LDA STATREG,Y
 LDA DATAREG,Y
 LDA STATREG,Y
 LDA IRQV
 STA $3FE
 LDA IRQV+1
 STA $3FF
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

* INITSSC: initialize SSC for use, dropping DTR.
* DOBAUD entry point will set baud without hanging up.
* Destroys all registers.

INITSSC SEI
 LDY SLOT16 get slot offset
 LDA #$0
 STA STATREG,Y reset acia
 STA CMDREG,Y dropping DTR here
* LDA #20
* JSR DELAYTICS
 LDY SLOT16
 LDA #%00001001 enable DTR and rcvr irqs
 STA CMDREG,Y fall through to DOBAUD

* DOBAUD: Set baud rate without resetting 6551

DOBAUD SEI
 LDY BAUD ;check user's value
 CPY #6+1 ;outside legal range?
 BGE :BAD
 CPY #0 ;zero?
 BNE :GOOD
:BAD LDY #5 ;force to 9600 if bad

:GOOD
 LDA #%00010000 set baud rate (won't hang up)
 LDX BAUD
 LDY SLOT16
 ORA BAUDOR-1,X into baud 'or' table
 STA CTRLREG,Y
 LDA STATREG,Y updates all registers in 6551
 CLI
 RTS

* HANGUP: drop DTR, disable 6551 IRQ's, & return.
* Destroys A,Y.
* HANGUPM entry displays copyright message.

HANGUPM
*
*HANGUPM LDA RCODE ;check result code
* BEQ PRIGHTS ;normal logoff, do copyright
* CMP #3
* BEQ PRIGHTS ;local logoff, do copyright
* BNE HANGUP ;otherwise, no copyright
*
*PRIGHTS JSR RIGHTS

HANGUP SEI

 JSR DELAY1

 LDY SLOT16 get slot offset
 LDA #$0
 STA STATREG,Y reset acia
 STA CMDREG,Y dropping DTR here
 LDA #20
 JSR DELAYTICS
 LDY SLOT16
 LDA #%00001001 enable DTR and rcvr irqs
 STA CMDREG,Y

 LDA #60
 JSR DELAYTICS ;pause just over 1 second
 JSR MPRINT ;send Hayes escape code
 ASC '+++',00
 LDA #80
 JSR DELAYTICS ;pause just over 1 second
 JSR MPRINT ;send Hayes hangup command
 ASC 'ATH',0D00
 JSR DELAY1 ;wait for it to come to pass...
 JSR CLRMBUF ;clear buffer of result

 CLI
 CLC
 RTS

* Baud Rate 'OR' table for 6551

BAUDOR DFB $06 300 baud 'or' value
 DFB $08 1200
 DFB $0A 2400
 DFB $0C 4800
 DFB $0E 9600
 DFB $0F 19200

* IRQIN: handle interrupts from 6551, which is set to
* cause an irq if dsr (carrier) changes state or if
* there is incoming data. Maintains DCDSTATE. Adds any
* input to MBUF. A, X destroyed. Y holds slot $n0.

IRQIN PHA  ;save registers
 PHX
 PHY

 LDY SLOT16 ;get status
 LDA STATREG,Y

 TAX  ;save 6551 status
 AND #%01000000 ;save DCD state
 STA DCDSTATE ;non-zero means offline
 TXA  ;restore 6551 status
 BPL :OURS

:DATACHK AND #%00001000 ;incoming data?
 BNE :MAYBE ;if so, check for errors
 BEQ :OURS ;always.

:MAYBE TXA  ;restore saved status
 AND #%00000111 ;mask all but err bits
 BEQ :SKIP ;good char.
 LDA DATAREG,Y ;waste data

 JMP :OURS

:SKIP LDA DATAREG,Y
 LDX MBUFTAIL ;tail index
 STA MBUF,X ;put at end of buf
 INC MBUFTAIL ;inc pointer

 LDX MBUFHEAD
 CPX MBUFTAIL ;full?
 BNE :OURS ;no, exit
 DEC MBUFTAIL ;yes, decrement.

:OURS LDA STATREG,Y ;read again
 LDA DATAREG,Y ;read again
 PLA  ;restore registers
 PLX
 PLY
 CLI
 RTI  ;return from interrupt

* MOUT: send character in A to modem, regardless of
* carrier state. Preserves all registers.

MOUT STY :TEMPY
 STA :TEMPA
 STX :TEMPX
 LDY SLOT16
:SEND LDA STATREG,Y
 AND #%00010000 ;ready to send yet?
 BNE :READY

 LDX #$40 ;was $80.
:WAIT NOP  ;short delay
 DEX  ;to prevent overwriting
 BNE :WAIT ;incoming irq's...
 BEQ :SEND

:READY LDA :TEMPA get char to send
 STA DATAREG,Y
 LDY :TEMPY restore and exit
 LDX :TEMPX
 RTS

:TEMPA DS 1
:TEMPY DS 1
:TEMPX DS 1


* MBUFCHK: see if data ready in MBUF.
* BEQ for no data, BNE for data.

MBUFCHK SEI
 LDX MBUFTAIL get tail index
 CPX MBUFHEAD compare to head index
 CLI  if different, data is
 RTS  ready.

* CLRMBUF: clear mbuf.

CLRMBUF SEI
 STA :TEMPA
 STY :TEMPY
 STZ MBUFHEAD ;reset buffer pointers
 STZ MBUFTAIL
 LDY SLOT16
 LDA STATREG,Y ;ensure no irq pending
 LDA DATAREG,Y ;and no data available.
 LDA :TEMPA
 LDY :TEMPY
 CLI
 RTS
:TEMPA DS 1
:TEMPY DS 1

* MBUFIN: get a byte from mbuf.

MBUFIN SEI
 LDX MBUFHEAD get head index
 LDA MBUF,X get byte from head
 INC MBUFHEAD inc head index
 CLI
 RTS
