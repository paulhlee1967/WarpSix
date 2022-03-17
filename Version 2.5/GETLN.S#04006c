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
:NOTIME   ;time's up!

* Disabled sysop immunity to timeouts for v2.5.
*
*:NOTIME LDA LEVEL
* CMP #9
* BEQ :TIME0

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
 LDA #78 ;set word wrap to 78 chars.
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
