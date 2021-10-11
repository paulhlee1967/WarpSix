* TOBASIC: Stuff char in LINBUF for BASIC.
* Prints current char to current output. Output is
* conditioned by MODEFLG. (Asterisk output if on.)
* Initiate word wrap if EOL reached in msg entry.
* Calls: COUT, WRAP, PRBFB. Destroys all registers.
* HOTFLG and HOTECHO determine hot key behaviour

TOBASIC BIT HOTFLG ;hotkeys on?
 BPL :NOTHOT ;no.
   ;using BIT rather than LDA for speed
   ;but LDA would allow more testing
   ;if execution falls through, hotkeys are on



:CR CMP #$8D ;CR?
 BNE :HOT

 STZ HOTFLG ;turn off hotkey flag after CR
   ;are we sure we want to do this now?

 BIT HOTECHO ;echo the CR?
 BMI :NORMAL ;yes
 JMP :CROUT ;no, just process eol

:HOT LDX NUMCHAR ;add input to buffer
 AND #%01111111 ;kill high bit for basic
 STA LINBUF,X ;put it in the buffer
 ORA #%10000000 ;hit high bit for COUT

 INC NUMCHAR ;increment char counter
 BIT HOTECHO ;echo input?
 BPL :HOTOUT
 JSR COUT ;print it

:HOTOUT LDA #$8D
 BRA :CR

:NOTHOT CMP #$88 ;BS?
 BEQ :BS
 CMP #$8D ;CR?
 BEQ :NORMAL ;yes, so can't be hidden

* Normal character received; check if wrap required

 LDY NUMCHAR
 CPY VIDW ;are we at video width?
 BNE :NOWRAP ;No, continue.

* If message entry flag is on, call word wrap routine

 BIT ENTFLG ;Message flag on?
 BPL :SLAP ;No, do nothing.
 JSR WRAP ;Do wordwrap.
 BRA :CROUT ;Return line to Applesoft.
:NOWRAP LDY MODEFLG ;hidden or normal?
 BEQ :NORMAL
 TAX  ;save char in A
 CPY #1 ;MODEFLG = 1 = invisible
 BEQ :NOTHING
 LDA #$AA ;load an asterisk
 JSR COUT ;print it
:NOTHING TXA  ;restore real input
 BRA :FILLBUF ;put in buffer

:BS LDY NUMCHAR ;0?
 BNE :BSOK
:SLAP TAY  ;to condition status reg
 TYA
 RTS  ;return w/ garbage char
:BSOK DEC NUMCHAR ;for INBUF

 PHA
 LDY MODEFLG
 CPY #1 ;invisible mode?
 BEQ :BSDONE ;if so, don't touch screen
 JSR PRBFB ;Print <bs><sp><bs>.
:BSDONE PLA
 RTS  ;return with char in A

:NORMAL PHA  ;save char
 CMP #$8D ;CR?
 BNE :NORMAL1
 JSR CLRCUR ;clear to end of line
:NORMAL1 PLA ;restore char
 JSR COUT ;print char

:FILLBUF CMP #$8D ;end of line?
 BEQ :CROUT ;yes, pass to Applesoft
 LDX NUMCHAR ;add input to buffer
 AND #%01111111 ;kill high bit for basic
 STA LINBUF,X ;put it in the buffer
 INC NUMCHAR ;increment char counter
 ORA #%10000000 ;restore high bit
 RTS  ;return with char in A

:CROUT LDX NUMCHAR ;get current index
 STZ LINBUF,X ;stuff a zero there

 BIT CHATFLG
 BPL :BASIC
 STZ NUMCHAR
 RTS

* Enter with null terminated string in LINBUF
* and string length in NUMCHAR. Null string
* has length of zero and zero terminator in buffer.

:BASIC STZ MODEFLG ;kill hidden mode at EOL
 LDA NUMCHAR ;load num of chars
 LDY #$02 ;3rd byte of descriptor
 STA (VARTAB),Y ;store string length
 INY  ;increment for next byte
 LDA #<LINBUF ;LSB of string start adr
 STA (VARTAB),Y
 INY  ;increment for next byte
 LDA #>LINBUF ;MSB of string start adr
 STA (VARTAB),Y
:DONE LDA #0
 STA NUMCHAR ;reset counter
 RTS  ;flag success (0 in A)
