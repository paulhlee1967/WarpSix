* Warp Six BBS standard routines
* Public domain version 2.0

* Wordwrap data area

WWCHAR DFB $0 ;Number of chars in ww buf.
WTMPCH DFB $0 ;Holds wrap character.
WTMPN DFB $0 ;Holds true line length.

GETLN BIT WWACTV Any data in wordwrap buf?
 BPL :CURSOR
 JSR WWPRNT Print wordwrap buffer.
:CURSOR JSR SHOWCUR put cursor on local screen
:TIME0 LDA TIMEOUT
 STA MINUTES
 LDA #60
 STA SSECONDS
 STA STICS
 STZ :WARNFLG

:GET LDA RCODE
 BNE :ALLOUT
 LDA KEYBD key down?
 BPL :MODEM
 BIT OAKEY command?
 BMI :KEYCMD
 BIT LOCALFLG keyboard active?
 BPL :MODEM
 STA STROBE clear for next time
:CHAR JSR FILTER
 BCS :TIME
 JSR TOBASIC
 BNE GETLN
:ALLOUT JSR UPDATE
 CLC
 RTS
:MODEM BIT REMFLG
 BPL :TIME
 LDY DCDSTATE
 BNE :NODCD
 JSR MBUFCHK
 BEQ :TIME
 JSR MBUFIN
 BRA :CHAR
:TIME BIT CHATFLG ;ignore timeout in chat
 BMI :GET

 JSR CHKVBL
 LDA MINUTES
 BEQ :NOTIME
 CMP #1
 BNE :GET
 BIT :WARNFLG
 BMI :GET
 LDA SSECONDS
 CMP #30+1
 BGE :GET
 JSR WARN
 LDA #$FF
 STA :WARNFLG
 BRA :GET
:NOTIME LDA LEVEL
 CMP #9
 BEQ :TIME0
 JMP TIMESUP

:NODCD JSR DCDLOST
 BRA :ALLOUT
:WARNFLG DS 1

* Process keyboard command

:KEYCMD STA STROBE
 JSR UPSHIFT
 CMP #"A" activate keyboard toggle?
 BEQ :ACTKEY
 CMP #"L" logoff?
 BEQ :LOGOFF
 CMP #"C" chat?
 BEQ :CHAT
 CMP #"K" kill?
 BEQ :KILL
:NOCMD JMP :GET

:ACTKEY LDY LOCALFLG already active?
 BEQ :ACTVON no, turn on
 BIT CHATFLG is chat on?
 BMI :NOCMD yes, command illegal
 STZ LOCALFLG
 STZ CHATFLG ensure CHAT off
 JMP :GET

:ACTVON LDA #$FF enable local keyboard
 STA LOCALFLG
 JMP :GET

:LOGOFF BIT LOCALFLG
 BPL :GOGET local keyboard must be on
 JSR CLRCUR
 LDA #3 logoff code
 STA RCODE
 JSR DCD2
:GOGET JMP :GET

:KILL JSR CLRCUR
 LDA #4 kill call return code
 STA RCODE
 JSR DCD2
 JMP :GET

:OLDCASE DFB $0 save area for ucaseflg

:CHAT BIT CHATFLG ;chat active?
 BPL :SYSON ;no
 STZ LOCALFLG ;shut off local keybd
 STZ CHATFLG ;turn off chat flag
 LDA :OLDCASE ;load caseflg we saved
 STA UCASEFLG ;restore flag
 LDA :HOTSAVE ;load hotflg we saved
 STA HOTFLG ;restore flag
 LDA :ENTSAVE
 STA ENTFLG
 LDA :MODESAVE
 STA MODEFLG
 LDA :VIDSAVE
 STA VIDW
 STZ NUMCHAR
 STZ WWCHAR
 STZ WWACTV
 JSR CLRCUR
 JSR PRINT ;print off message
 HEX 8D8D
 ASC "Chat end : ",00
:GOLN JMP GETLN
:GONOCMD JMP :NOCMD

:SYSON BIT REMFLG ;is there a remote user?
 BPL :GONOCMD ;if no, command illegal

 STZ OURCH
 JSR CLREOL

 LDA HOTFLG ;save hot key flag
 STA :HOTSAVE
 LDA UCASEFLG ;save case flag
 STA :OLDCASE
 LDA ENTFLG ;save message entry flag
 STA :ENTSAVE
 LDA MODEFLG ;save mode flag
 STA :MODESAVE
 LDA VIDW ;save video width
 STA :VIDSAVE
 LDA #77 ;set word wrap to 77 chars.
 STA VIDW
 STZ UCASEFLG ;set for full case
 STZ HOTFLG ;kill hot keys
 STZ NUMCHAR ;zero line buffer
 STZ WWCHAR ;zero word wrap char
 STZ WWACTV ;zero flag for chars to wrap
 STZ MODEFLG ;shut off hidden mode
 LDA #$FF
 STA LOCALFLG ;enable local keybd
 STA ENTFLG ;enable word wrap
 STA CHATFLG ;turn on chat flag
 JSR PRINT
 HEX 8D8D
 ASC "Chat :",8D8D8700
 BRA :GOLN
:HOTSAVE DS 1
:ENTSAVE DS 1
:VIDSAVE DS 1
:MODESAVE DS 1

SHOWCUR PHA

 LDA OURCH
 CMP #79
 BLT :NORMAL

 INC WNDWDTH ;to prevent scrolling
 INC WNDWDTH ;when cursor hits col 80.

:NORMAL LDA #"_" ;get cursor
 JSR C3COUT1 ;print it
 LDA #$88 ;print backspace
 JSR C3COUT1

 LDA OURCH
 CMP #79
 BLT :EXIT

 DEC WNDWDTH ;restore window width.
 DEC WNDWDTH

:EXIT PLA
 RTS

* OUTPUT routine. Connected with PR#A$nnnn
* This routine is handles output via COUT. Output
* (including basic PRINT statements) passes through
* here. Routes to screen, or modem and screen.
* Calls: MOUT, C3COUT1, DCDLOST.

OUTPUT STA :OUTTEMP
 PHA
 PHX
 PHY

 BIT REMFLG is modem active?
 BPL :OUTEX no, dump to screen only
 LDY DCDSTATE carrier present?
 BNE :NOCARR no

* Modem filter

 BIT PSEFLAG
 BMI :MODEMCK in PSE mode, no filter.

 CMP #$A0 non control?
 BGE :MODEMCK
 CMP #$8D cr?
 BEQ :MODEMCK
 CMP #$88 backspace?
 BEQ :MODEMCK
 CMP #$87 ^G?
 BEQ :MODEMCK
 CMP #$8C ^L?
 BEQ :MODEMCK
 BNE :EXIT ;filter it!

:MODEMCK AND #%01111111 kill high bit of output
 JSR MOUT
 ORA #%10000000 restore high bit

 CMP #$8D was it CR?
 BNE :OUTEX if not, we're done.

 BIT LFFLAG send LF flag on?
 BPL :OUTEX if not, we're done

 LDA #$8A add line feed after CR
 BRA :MODEMCK

:NOCARR JSR DCDLOST inform BASIC

:OUTEX LDA :OUTTEMP

 BIT PRIVATE private mode?
 BMI :EXIT if so, no screen output

 CMP #$8D
 BEQ :SCRPRT

 CMP #$88
 BEQ :SCRPRT

 CMP #$8C allow ^L to clear screen
 BEQ :SCRPRT

 CMP #$A0 control character?
 BLT :EXIT don't print it

:SCRPRT JSR C3COUT1 80 column printchar

:EXIT PLY
 PLX
 PLA
 CLC  ;is this necessary?
 RTS
:OUTTEMP DS 1

* TOBASIC: stuff char in LINBUF for basic.
* Prints current char to current output. Output is
* conditioned by MODEFLG. (Asterisk output if on.)
* Initiate word wrap if EOL reached in msg entry.
* Calls: COUT, WRAP, PRBFB. Destroys all registers.

TOBASIC BIT HOTFLG hotkeys on?
 BPL :NOTHOT no.

:CR CMP #$8D CR?
 BNE :HOT

 STZ HOTFLG turn off hotkey flag after CR

 BIT HOTECHO echo the CR?
 BMI :NORMAL yes
 JMP :CROUT no, just process eol

:HOT LDX NUMCHAR add input to buffer
 AND #%01111111 kill high bit for basic
 STA LINBUF,X put it in the buffer
 ORA #%10000000 hit high bit for COUT

 INC NUMCHAR increment char counter
 BIT HOTECHO echo input?
 BPL :HOTOUT
 JSR COUT print it

:HOTOUT LDA #$8D
 BRA :CR

:NOTHOT CMP #$88 BS?
 BEQ :BS
 CMP #$8D CR?
 BEQ :NORMAL yes, so can't be hidden

* Normal character received; check if wrap required

 LDY NUMCHAR
 CPY VIDW are we at video width?
 BNE :NOWRAP No, continue.

* If message entry flag is on, call word wrap routine

 BIT ENTFLG Message flag on?
 BPL :SLAP No, do nothing.
 JSR WRAP Do wordwrap.
 BRA :CROUT Return line to Applesoft.
:NOWRAP LDY MODEFLG hidden or normal?
 BEQ :NORMAL
 TAX  save char in A
 CPY #1 MODEFLG = 1 = invisible
 BEQ :NOTHING
 LDA #$AA load an asterisk
 JSR COUT print it
:NOTHING TXA  restore real input
 BRA :FILLBUF put in buffer

:BS LDY NUMCHAR 0?
 BNE :BSOK
:SLAP TAY  to condition status reg
 TYA
 RTS  return w/ garbage char
:BSOK DEC NUMCHAR for INBUF

 PHA
 LDY MODEFLG
 CPY #1 invisible mode?
 BEQ :BSDONE if so, don't touch screen
 JSR PRBFB Print <bs><sp><bs>.
:BSDONE PLA
 RTS  return with char in A

:NORMAL PHA ;save char
 CMP #$8D ;CR?
 BNE :NORMAL1
 JSR CLRCUR ;clear to end of line
:NORMAL1 PLA ;restore char
 JSR COUT ;print char

:FILLBUF CMP #$8D end of line?
 BEQ :CROUT yes, pass to Applesoft
 LDX NUMCHAR add input to buffer
 AND #%01111111 kill high bit for basic
 STA LINBUF,X put it in the buffer
 INC NUMCHAR increment char counter
 ORA #%10000000 restore high bit
 RTS  return with char in A

:CROUT LDX NUMCHAR get current index
 STZ LINBUF,X stuff a zero there

 BIT CHATFLG
 BPL :BASIC
 STZ NUMCHAR
 RTS

* Enter with null terminated string in LINBUF
* and string length in NUMCHAR. Null string
* has length of zero and zero terminator in buffer.

:BASIC STZ MODEFLG kill hidden mode at EOL
 LDA NUMCHAR load num of chars
 LDY #$02 3rd byte of descriptor
 STA (VARTAB),Y store string length
 INY  increment for next byte
 LDA #<LINBUF LSB of string start adr
 STA (VARTAB),Y
 INY  increment for next byte
 LDA #>LINBUF MSB of string start adr
 STA (VARTAB),Y
:DONE LDA #0
 STA NUMCHAR reset counter
 RTS  flag success (0 in A)

* WRAP: Searches back for space wraps word to next line.
* Uses A, X & Y.

WRAP CMP #$A0 Is wrapping character a space?
 BNE :DOWRAP No, do the wrap.

 JSR COUT print space to erase cursor

 PHA  save A
 LDA OURCH check we didn't drop a line
 CMP #2 cursor pos'n near left?
 BGE :QUICK then don't print CR.

:SLICK LDA #$88 ;erase the space
 JSR COUT
 PLA
 RTS

:QUICK JSR CROUT otherwise, print CR.
 PLA
 RTS

:DOWRAP AND #%01111111 kill high bit
 STA WTMPCH Save wrapping char.
 LDX NUMCHAR get character count
 DEX  look at last character
 LDY #31 Look back maximum of 30 chars.
:CHKCHR LDA LINBUF,X get char
 CMP #$20 a space?
 BEQ :FNDSPC Yes. Wrap the word.
 DEX
 DEY
 BNE :CHKCHR Keep checking.

 STZ WWCHAR Truncate: place char on next line.

 LDA WTMPCH save the one character in wwbuf.
 STA WWBUF
 LDA #$A0 print space to erase cursor
 JSR COUT
 BRA :EXIT

:FNDSPC LDY #0 found a space
 STX WTMPN mark as true pos'n of e-o-l
 INX
 BRA :ERASE start loop with bs<sp>bs

:COPCHR CPX NUMCHAR Finished copying wrap data?
 BEQ :COPDON Yes.
 LDA LINBUF,X get next char from buf
 STA WWBUF,Y save in our buf
 INX  point to next buf char
 INY  inc our buf ptr
:ERASE JSR PRBFB
 BRA :COPCHR loop always

:COPDON LDA WTMPCH Save wrap char.
 STA WWBUF,Y save
 STY WWCHAR Save wwbuf length.
 LDX WTMPN get real eol
 STX NUMCHAR Save true length of line.
 INC NUMCHAR

:EXIT LDA #$FF Set wordwrap active.
 STA WWACTV
 JSR CROUT
 RTS

* WWPRNT: print contents of wordwrap buffer.
* Uses A and X.

WWPRNT LDX #0 Zero byte counter.
 INC WWCHAR inc to total + 1 for compare
:PRCHR LDA WWBUF,X get char from our buf
 STA LINBUF,X Put char in line buf.
 ORA #%10000000 set high bit
 JSR COUT print it.
 INX  point to next
 CPX WWCHAR Finished?
 BNE :PRCHR always
:WWDONE LDX WWCHAR Set line counter.
 STX NUMCHAR
 STZ WWCHAR
 STZ WWACTV
 RTS  and we're done.

CLRCUR LDA #$A0 erase cursor
 JSR C3COUT1
 LDA #$88
 JMP C3COUT1

PRBFB JSR CLRCUR

 LDA #$88
 JSR COUT
 LDA #$A0
 JSR COUT
 LDA #$88
 JMP COUT

* FILTER: filters bad ctrl chars, converts input
* to uppercase if flag is on.
* C=1 means input was filtered. C=0 means input okay
* (or modified) and will be found in A.
* Calls: UPSHIFT, PRBFB. Destroys X,Y. Result in A.

FILTER ORA #%10000000 ensure high bit set
 CMP #$8D CR?
 BEQ :CHAROK
 CMP #$FF delete?
 BEQ :RUBOUT
 CMP #$88 backspace?
 BEQ :CHAROK
* CMP #$89 tab?
* BEQ :DOTAB
 CMP #$98 ctrl-X?
 BEQ :ERASELN
 CMP #$A0 ctrl char still there?
 BLT :NOCHAR2 yes, trash it
:CASECHK LDX UCASEFLG
 BEQ :CHAROK
 CPX #255
 BEQ :UP
:DOWN JSR DNSHIFT
 CLC
 RTS
:UP JSR UPSHIFT convert to uppercase
:CHAROK CLC  flag char as okay
 RTS  and return with char in A
:RUBOUT LDA #$88 convert to backspace
 BNE :CHAROK always
:NOCHAR2 SEC  flag char as bad
 RTS  and return with char in A
:ERASELN
 PHA  save char on stack

 LDA MODEFLG
 CMP #1 invisible mode?
 BNE :GO if not, erase
 STZ NUMCHAR nuke line, don't touch screen
 BRA :NOERASE

:GO LDA NUMCHAR
 BEQ :NOERASE already at line start
:ERASE JSR PRBFB Print <bs> <sp> <bs>
 DEC NUMCHAR
 BNE :ERASE not at beginning of line yet
 JSR CLRMBUF make sure no junk appears
 JSR SHOWCUR
:NOERASE PLA  restore A
 SEC
 RTS

UPSHIFT CMP #"z"+1
 BGE :NO
 CMP #"a"
 BLT :NO
 AND #%11011111 convert to uppercase
:NO RTS

DNSHIFT CMP #"A"
 BLT :NO
 CMP #"Z"+1
 BGE :NO
 ORA #%00100000 convert to lowercase
:NO RTS

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

* TYPE: Dump file to current output, with Xon/Xoff
* protocol, space to abort (if FILESTOP off), SPACE will
* set SPLABORT flag, RETURN will set NXTFLG.
* Calls: CLRMBUF, SETTMOUT, DECTMOUT, COUT, MBUFCHK,
* MBUFIN, DCDLOST, MLI (Open, read, close).
* Clobbers all registers.

TYPE JSR CLRMBUF kill any random data
 STZ SPLABORT
 STZ NXTFLG

 LDA VPATH1 ;set pointer to filename
 STA OPATH
 LDA VPATH1+1
 STA OPATH+1

 JSR OPEN
 BEQ :NEXT
 JMP :ERR2

:NEXT LDA OREFNUM get refnum
 STA RREFNUM save for read
 STA CLREFNUM save for close

 LDA #<CBUF
 STA RBUFPTR
 LDA #>CBUF
 STA RBUFPTR+1
 LDA #1 one byte at a time
 STA RREQCNT
 STZ RREQCNT+1
 STZ LASTCH

:READ JSR MLI
 DFB #$CA
 DA RPARMS
 BNE :CLOSE2

 LDA RCODE carrier ok?
 BNE :ABORT if not, abort.

 LDA CBUF get current byte
 ORA #%10000000 set high bit

 CMP #$8D ;cr?
 BNE :PRINT

* Here is a CR character

 LDY LASTCH ;get last cursor pos'n
 CPY #79
 BEQ :NOPRINT

:PRINT
 LDY OURCH save last OURCH
 STY LASTCH
 JSR COUT otherwise, print to current output

:NOPRINT LDA KEYBD keybd input?
 BPL :MODEM no input, check modem
 STA STROBE clear keybd for next time

:CHECKS CMP #$8D CR?
 BNE :XOFFCHK
 LDY FILESTOP allowed to abort?
 BNE :XOFFCHK no, can't goto next
 LDA #$FF
 STA NXTFLG set next bulletin flag
 BNE :ABORT always abort for next
:XOFFCHK CMP #$93 control-S?
 BEQ :GOXONWAIT
 BNE :ABTCHK
:ABTCHK CMP #$A0 space? (only from modem)
 BNE :READ no other input valid
 LDY FILESTOP user allowed to abort?
 BNE :READ no.
 LDA #$FF
 STA SPLABORT abort spool as well as
 JMP :ABORT abort file read.

:GOREAD JMP :READ and continue file read

:ERR2 JSR BADCALL
:ERR2A JMP ERROUT let BI handle unexpected error

:MODEM LDY REMFLG modem active?
 BEQ :READ

 JSR MBUFCHK any input from modem?
 BEQ :READ no data

 JSR MBUFIN get char and check
 ORA #%10000000
 JMP :CHECKS

:ABORT JSR CROUT print 2 CR's and fall through
 JSR CROUT

:END LDA #0 flag no error

:CLOSE2 PHA  save error code if any
 JSR CLOSE
 PLA  recover err code
 BEQ :OK
 CMP #$4C end of file encountered?
 BNE :ERR2 no, real error
:OK CLC  inform BI all is well
 RTS  return to BI.

:GOXONWAIT LDA XTMOUT
 STA SECONDS
 LDA #60
 STA STICS

:XONWAIT JSR CHKVBL
 LDA SECONDS
 BEQ :GOREAD timed out, continue output.

 LDA KEYBD keybd has priority
 BPL :MOD
 STA STROBE
 CMP #$91 XON from keybd?
 BEQ :GOREAD
 CMP #$8D CR from keybd?
 BEQ :GOREAD
 CMP #$A0
 BEQ :GOREAD

:MOD BIT REMFLG
 BPL :XONWAIT

 LDY DCDSTATE carrier present?
 BNE :DCDLOST

 JSR MBUFCHK any modem input?
 BEQ :XONWAIT if not, loop.

 JSR MBUFIN get character
 ORA #%10000000 set high bit
 CMP #$91 XON? (Control-Q)
 BEQ :GOREAD yes, continue with output
 CMP #$8D CR? (substitute XON)
 BEQ :GOREAD yes, continue with output
 CMP #$A0 space?
 BEQ :GOREAD
 BRA :XONWAIT invalid input, keep waiting

:DCDLOST JSR DCDLOST
 JMP :END

CBUF DS 1 char bufr for read
LASTCH DS 1

WARN JSR PRINT
 HEX 8D8D
 ASC "Hello? : ",8700
 BIT LOCALFLG
 BPL :DONE
 JSR BELL
:DONE JMP SHOWCUR

TIMESUP JSR CLRCUR
 JSR PRINT
 HEX 8D8D
 ASC "Goodbye.",8D00
 JSR RIGHTS
 JSR HANGUP
 LDY #1 return time out code
 STY RCODE
 JMP DCD3

* LOGON: save time user logged on at

LOGON JSR GETTIME
 LDA TIME+1 hour
 STA STARTHR save logon time
 LDA TIME minutes
 STA STARTMIN
:EXIT RTS  and exit.

* Copyright message routine

RIGHTS LDX #0
:PRINT LDA :MSG,X
 EOR #$AB
 BEQ :EXIT
 JSR COUT
 INX
 BNE :PRINT ;always (stringlen < 255 always)
:EXIT RTS

* 123456789 123456789 123456789 1234567890

* Warp Six BBS, created by Jim Ferr.
* Public domain version 2.0.

:MSG HEX 26 ;cr
 HEX 7C4A595B0B7842530B ;Warp Six
 HEX 696978070B ;BBS,
 HEX 48594E4A5F4E4F0B ;created
 HEX 49520B ;by
 HEX 6142460B ;Jim
 HEX 6D4E595905 ;Ferr.
 HEX 26 ;cr
 HEX 7B5E494742480B ;Public
 HEX 4F44464A42450B ;domain
 HEX 5D4E59584244450B ;version
 HEX 19051B05 ;2.0
 HEX 2626AB ;cr cr end
