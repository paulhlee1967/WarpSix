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
