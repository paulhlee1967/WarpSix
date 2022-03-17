* Parse routine for external commands: TYPE, SEND
* and RECEIVE.

PARSE LDA VPATH1 pointer to command buf
 STA :PARSPTR+1 save it
 STA :PARSPTR2+1
 STA :PARSPTR3+1
 STA :PARSPTR4+1
 LDA VPATH1+1
 STA :PARSPTR+2
 STA :PARSPTR2+2
 STA :PARSPTR3+2
 STA :PARSPTR4+2

:1 LDX #4 check first four chars
:PARSPTR LDA $FFFF,X get a char
 CMP :OURCMD-1,X compare it to 'TYPE'
 BEQ :FOUND
 BNE :2

:FOUND DEX  for next char
 BNE :PARSPTR
 LDA #<TYPE TYPE address
 STA XTRNADDR
 LDA #>TYPE
 STA XTRNADDR+1

:GOOD STZ XCNUM tell BI ext.cmd active
 LDA #3 length of cmd-1
 STA XLEN
 LDA #%00000101 tell BI which parms
 STA PBITS are permitted
 LDA #%00000100
 STA PBITS+1
 CLC  claim the command
 RTS  return to the BI

:2 LDX #4 ;don't parse.

:PARSPTR2 LDA $FFFF,X
 CMP :OURCMD2-1,X ;SEND?
 BEQ :FOUND1
 BNE :3 check receive

:FOUND1 DEX  for next char
 BNE :PARSPTR2

 LDA #<SENDV vector to SEND address
 STA XTRNADDR
 LDA #>SENDV
 STA XTRNADDR+1
 BRA :GOOD

:3 LDX #7
:PARSPTR3 LDA $FFFF,X
 CMP :OURCMD3-1,X ;RECEIVE?
 BEQ :FOUND2
 BNE :4 ;check COPY

:FOUND2 DEX
 BNE :PARSPTR3

 LDA #<RECEIVEV ;vector to RECEIVE address
 STA XTRNADDR
 LDA #>RECEIVEV
 STA XTRNADDR+1
 STZ XCNUM tell BI ext.cmd active
 LDA #6 length of cmd-1
 STA XLEN
 LDA #5 tell BI which parms
 STA PBITS are permitted
 LDA #4
 STA PBITS+1
 CLC  claim the command
 RTS  return to the BI

:NOT SEC  not ours
 JMP OLDEXV jump to old xtrn vector

:4 LDX #4
:PARSPTR4 LDA $FFFF,X
 CMP :OURCMD4-1,X ;COPY?
 BEQ :FOUND3
 BNE :NOT

:FOUND3 DEX
 BNE :PARSPTR4

 LDA #<COPYV ;vector to RECEIVE address
 STA XTRNADDR
 LDA #>COPYV
 STA XTRNADDR+1

 STZ XCNUM tell BI ext.cmd active
 LDA #3 length of cmd-1
 STA XLEN

 LDA #3
 STA PBITS two filenames expected
 LDA #0
 STA PBITS+1 slot and drive not allowed

 CLC  claim the command
 RTS  return to the BI

:OURCMD ASC 'TYPE'
:OURCMD2 ASC 'SEND'
:OURCMD3 ASC 'RECEIVE'
:OURCMD4 ASC 'COPY'
