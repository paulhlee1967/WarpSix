
CATALOG

* ProDOS Catalog Routine
* (from ProDOS 8 Technical Note #17)

* by Greg Seitz 12/83
*     Pete McDonald 1/86
*     Keith Rollin 7/88
*     Dave Lyons 11/89
*     Jim Ferr 12/90

* Recursive code removed for Warp Six.
* One bug fix made for Warp Six
* (removed erroneous Dec BEntry)
* ...lots of neat stuff added for Warp Six.

* Public domain version 2.4.

* Equates for catalog

* Zero page locations

DIRNAME EQU $80 ;pointer to directory name
ENTPTR EQU $82 ;ptr to current entry

* ProDOS command numbers

MLIGETPFX EQU $C7 ;get_prefix
MLIREAD EQU $CA ;read a file command
ENDOFFILE EQU $4C ;endoffile error

* Offsets into the directory

OTYPE EQU $0 ;offset to file type byte
OENTLEN EQU $23 ;length of each dir. entry
OENTBLK EQU $24 ;entries in each block

SPACE EQU $A0 ;a space character

* Use the current prefix for the name of the
* directory to display.  Note that the string we
* pass to readdir has to end with a "/", and that
* the result of get_prefix does.

 STZ FILES ;files printed flag

 JSR MLI
 DFB MLIGETPFX
 DA GETPPARMS
 BEQ :READY

 JMP MLIERR ;display error

:READY LDA #<NAMEBUFFER ;low byte
 LDX #>NAMEBUFFER ;high byte
 JSR READDIR
 RTS

READDIR

* This is the actual routine. It takes as
* input a pointer to the directory name to read in
* A,X (lo,hi), opens it, and starts to read the
* entries. When it encounters a filename, it calls
* the routine "visitfile".
*
* The directory pathname string must end with a "/"
* character.

 STA DIRNAME ;save a pointer to name
 STX DIRNAME+1

 STA OPATH ;set up openfile params
 STX OPATH+1

READDIR1 JSR OPENDIR ;open directory as a file
 BCS XDONE

 JSR PRHEADER ;print header for catalog

 STZ HOWMANY ;init counter for lines done

 JMP NEXTENTRY ;jump to the end of the loop

LOOP LDY #OTYPE ;get type of current entry
 LDA (ENTPTR),Y
 AND #$F0 ;look at 4 high bits
 CMP #0
 BEQ NEXTENTRY ;Inactive? - bump to next one

 CMP #$D0 ;directory file?
 BNE FND
 JMP NEXTENTRY

* Don't show finder or bad block files

FND LDY #$10 ;get file type byte
 LDA (ENTPTR),Y
 CMP #$C9 ;FND?
 BEQ NEXTENTRY ;if so, skip it
 CMP #$01 ;bad block file?
 BEQ NEXTENTRY ;if so, skip it

* Don't show files with .D or .H extension

 LDY #0 ;get byte that has the length byte
 LDA (ENTPTR),Y
 AND #$0F ;get just the length
 CMP #1
 BEQ GOVISIT ;filename 1 char long.

 TAY ;put length in y

 LDA (ENTPTR),Y ;load last character

 CMP #'D'
 BEQ PERIOD ;if so, check 2nd last

 CMP #'H' ;last character an H?
 BNE GOVISIT ;if not, display file.

PERIOD DEY
 LDA (ENTPTR),Y
 CMP #'.' ;period?
 BEQ NEXTENTRY ;if so, skip entry

** Addition to display locked files for level 9

GOVISIT
 LDY #$1E ;get access byte
 LDA (ENTPTR),Y
 BMI DOVISIT ;not locked, so print it!

 LDA LEVEL
 CMP #9
 BNE NEXTENTRY

** -- end of addition to display locked files for lvl 9

* Do whatever is necessary when we encounter a
* file entry in the directory.
* (print the entry)

DOVISIT JSR PRINTENTRY
 BCC :NEXT
 JSR CLOSE
 CLC
 RTS

:NEXT JSR CROUT

NEXTENTRY JSR GETNEXT ;get pointer to next entry
 BCC LOOP ;carry set means we're done

XDONE PHA ;save error code
 JSR CLOSE
 PLA ;we're expecting eof error
 CMP #ENDOFFILE
 BEQ HITDIREND
 JMP MLIERR

HITDIREND

 BIT FILES
 BMI :EXIT

 JSR PRINT
 ASC " No files available.",8D00

:EXIT RTS


OPENDIR

* Opens the directory pointed to by openparms
* parameter block. This pointer should be init-
* ialized before this routine is called. if the
* file is successfully opened, the following
* variables are set
*
*     XREFNUM     ;all the refnums
*     ENTRYLEN    ;size of directory entries
*     ENTPTR      ;pointer to current entry
*     THISBENTRY  ;entry number within this block
*     THISBLOCK   ;offset (in blocks) into dir.

 JSR OPEN
 BNE OPENDONE

 LDA OREFNUM
 STA XRREFNUM
 STA CLREFNUM

 JSR MLI ;read the first block
 DFB MLIREAD
 DA READPARMS
 BNE OPENDONE

 LDA BUFFER+OENTLEN ;init 'entrylen'
 STA ENTRYLEN

 LDA #<BUFFER+4 ;init ptr to first entry
 STA ENTPTR
 LDA #>BUFFER+4
 STA ENTPTR+1

 LDA BUFFER+OENTBLK ;init these values based
 STA THISBENTRY ;on values in the dir header
 STA ENTPERBLK

 LDA #0 ;init block offset into dir.
 STA THISBLOCK

 CLC ;say that open was OK
OPENDONE RTS

GETNEXT

* This routine is responsible for making a pointer
* to the next entry in the directory. If there are
* still entries to be processed in this block, then
* we simply bump the pointer by the size of the
* directory entry. If we have finished with this
* block, then we read in the next block, point to
* the first entry, and increment our block counter.

 DEC THISBENTRY ;dec count for this block
 BNE CONT
 JMP READNEXT ;done w/this block, get next

CONT CLC ;else bump up index
 LDA ENTPTR
 ADC ENTRYLEN
 STA ENTPTR
 LDA ENTPTR+1
 ADC #0
 STA ENTPTR+1
 CLC ;say that the buffer's good
 RTS


READNEXT
 JSR MLI ;get the next block
 DFB MLIREAD
 DA READPARMS
 BNE DIRDONE

 INC THISBLOCK

 LDA #<BUFFER+4 ;set entry pointer to
 STA ENTPTR ;beginning of 1st entry in
 LDA #>BUFFER+4 ;block
 STA ENTPTR+1

 LDA ENTPERBLK ;re-init 'entries in this
 STA THISBENTRY ;block'

 CLC ;return 'no error'
 RTS

DIRDONE SEC ;return 'an error occurred'
 RTS ;(error code in A)

* Using the pointer to the current entry, this
* routine prints the entry.
* Returns with carry clear if all okay,
* or carry set, if user wishes to abort.

PRINTENTRY

 INC HOWMANY
 LDA #$FF
 STA FILES ;set flag to indicate we
   ;printed some files.

FULLSCR LDA HOWMANY
 CMP #20 ;19 lines at a time
 BGE :PAGE
 JMP :GO ;continue

* Display prompt and take input

:PAGE
 STZ HOWMANY ;reset line counter

 LDA #60 ;set timeout
 STA SECONDS ;about 60 seconds
 STA STICS

 JSR PRINT
 HEX 8D
 ASC "Return to continue or A)bort : ",00

* Now get input from user

 JSR CURSORV

:KEY LDA KEYBD ;always check keyboard
 BPL :MODEM
 STA STROBE

:TEST
 ORA #%10000000 ;set high bit always

 CMP #$FB
 BGE :NO
 CMP #$E1
 BLT :NO
 AND #%11011111 convert to uppercase
:NO

 CMP #"A" ;A)bort?
 BNE :NEXTKEY ;continue test

:ABORT JSR COUT
 JSR CROUT
 SEC  ;abort
 RTS

:NEXTKEY CMP #$8D
 BNE :KEY ;loop until we have it
 BEQ :CONT


:MODEM BIT REMFLG ;user online?
 BPL :KEY ;if not, ignore modem.

 LDA DCDSTATE ;check for carrier
 BNE :ABORT ;abort on carrier loss!

:DATA JSR MBUFCKV
 BNE :MBYTE
 JSR CHKVBL
 LDA SECONDS
 BEQ :ABORT
 BNE :KEY

:MBYTE JSR MBUFINV ;get a byte
 JMP :TEST ;test it.

:CONT STA STROBE
 JSR CLREOL
 JSR CROUT
 JSR PRHEADER ;and fall through

** Lines below added to print locked names if SL=9

:GO LDY #$1E ;get file access byte
 LDA (ENTPTR),Y
 AND #$C2 ;if destroy, write or rename
 CMP #$C2 ;not enabled, then mark *
 BEQ SPACE1
 LDA #$AA ;*
 JSR COUT
 BNE NAME
SPACE1 LDA #$A0
 JSR COUT

** End of addition to print locked names

NAME LDY #0 ;get byte that has the length byte
 LDA (ENTPTR),y
 AND #$0F ;get just the length
 STA PRNTCNT ;put it into our counter
PRNTLOOP INY ;bump to the next char.
 LDA (ENTPTR),y ;get next char
 ORA #$80 ;cout likes high bit set
 JSR COUT ;print it
 DEC PRNTCNT ;printed all chars?
 BNE PRNTLOOP ;no - keep going

* we want to print spaces until column 17

SPLOOP CPY #16
 BGE DOTYPE
 LDA #SPACE
 JSR COUT
 INY
 BNE SPLOOP

DOTYPE TYA ;put count in A
 CLC
 ADC #3 ;add 3 for type
 STA PRNTCNT ;update print count

 LDY #$10 ;get file type of current entry
 LDA (ENTPTR),Y
 STA TMPTYP ;save it
 LDX #0
TLOOP LDA TNUM,X ;compare to types in table
 BEQ DOHEX ;if not found, print as hex
 CMP TMPTYP ;compare to our type
 BEQ DOASC ;go it!
 INX
 BNE TLOOP

DOHEX LDA #"$"
 JSR COUT
 LDA TMPTYP
 JSR PRBYTE
 JMP DOBYTES

DOASC LDY #0
 STY ACTR ;save counter
 CPX #0 ;is x zero?
 BEQ DOASC1 ;if zero, it's 1st entry

ASCINC INY ;inc 3 times for each x
 INY
 INY
 INC ACTR
 CPX ACTR ;compare x to actr
 BNE ASCINC

DOASC1 LDA TASC,Y ;print file type in ASCII
 JSR COUT ;(3 characters)
 LDA TASC+1,Y
 JSR COUT
 LDA TASC+2,Y
 JSR COUT

* Print file length in decimal

DOBYTES LDA #0
 STA ACCH ;TO INSURE GOOD HEX TO DEC CONVERSIONS
 LDA #" "
 LDX #7
SPACED STA LENBUF,X ;fill buffer with spaces
 DEX
 BNE SPACED
 STA LENBUF

CEOF LDY #$17 ;convert eof to ASCII
 LDA (ENTPTR),Y
 STA ACCH ;save high byte

 LDY #$16
 LDA (ENTPTR),Y
 TAX ;medium byte in X

 LDY #$15
 LDA (ENTPTR),Y ;low byte in A

 LDY #7 ;# of chars to print -1
 JSR HEXDEC

 JSR PRINTL ;print length

* Print last modified date

DODATE LDY #$22
 LDA (ENTPTR),Y ;get year
 LSR ;put hi bit of month into C
 PHP ;save carry status

 STA YEAR ;save year
 DEY
 LDA (ENTPTR),Y ;get month/day byte

 PHA ;save on stack
 AND #%00011111 ;extract day only
 STA DAY ;save the day <Grin>

 PLA ;restore month low bits
 PLP ;restore carry status
 ROR ;put hi bit of month in b7
 LSR ;shift all bits down
 LSR 
 LSR 
 LSR 
 STA MONTH

 BEQ NODATE ;branch on illegal date
 CMP #13 ;only 12 months in a year...
 BGE NODATE

 LDA DAY ;MAKE SURE DAY IS VALID.
 BEQ NODATE
 LDA YEAR ;MAKE SURE YEAR IS VALID.
 CMP #100 ;CANNOT BE > 99
 BLT DATE1

NODATE JSR PRINT
 ASC " <No Date>"
 HEX 00
 CLC
 RTS

* print space

DATE1 LDA #SPACE
 JSR COUT

* print day

 LDA DAY
 CMP #10 ;less than the 10th?
 BGE DAY2
 LDA #"0" ;print leading zero
 JSR COUT
DAY2 LDX DAY
 LDA #0
 JSR PRDEC

 LDA #"-"
 JSR COUT

* print month

 LDA MONTH
 ASL ;multiply by 3
 CLC
 ADC MONTH
 TAX

 LDY #0
DOMONTH LDA MONTHS-3,X ;MOVE MONTH MNEUMONIC.
 JSR COUT
 INX
 INY
 CPY #3
 BLT DOMONTH

* print year

 LDA #"-"
 JSR COUT

 LDX YEAR
 LDA #0
 JSR PRDEC ;convert to decimal
 CLC
 RTS

* Subroutines...

* Routine to print 3 byte file length in decimal
* After it has already been converted and sits in LENBUF

PRINTL JSR PRINT
 ASC " " ;print a space
LENBUF HEX A0A0A0A0A0A0A0A0 ;bytes
 HEX 00 ;zero byte marks end
 RTS


* Routine to convert three byte value to decimal
* High byte in ACCH
* Medium byte in X
* Low byte in A
* Number of chars -1 in Y

* Leaves result in LENBUF, with leading spaces
* if necessary.

HEXDEC
 STX ACCM
 STA ACCL
HEXDEC1 JSR DIVID10 ;/ by 10 & convert to modulo to ASCII
 LDA MOD
 ORA #$B0 ;make it ASCII 0-9
 STA LENBUF,Y ;from right to left
 DEY
 LDA ACCL
 ORA ACCM ;test for zero
 ORA ACCH
 BNE HEXDEC1 ;always
HEXDEC2 RTS

DIVID10 LDX #$18 ;for 24 bits
 LDA #0 ;zero out modulo
 STA MOD
DIV1 JSR SHFT24
 ROL MOD
 SEC
 LDA MOD
 SBC #$A
 BCC DIV2
 STA MOD
 INC ACCL
DIV2 DEX ;more bits?
 BNE DIV1
 RTS
SHFT24 ASL ACCL
 ROL ACCM
 ROL ACCH
 RTS

*    Print decimal routine
*
* Enter routine with number in
* A,X (hi,low). JUST must hold
* $A0 for right justification
* or anything positive for
* left justification.
*
* From Merlin Pro.

PRDEC STA NH
 STX NL
 LDX #9
 STX NFL
LOAD0 LDY #"0"
DIV LDA NL
 CMP NUMTBL-1,X
 LDA NH
 SBC NUMTBL,X
 BCC DIVD
 STA NH
 LDA NL
 SBC NUMTBL-1,X
 STA NL
 INY
 BNE DIV
DIVD TYA
 DEX
 BEQ PRD
 CMP #"0"
 BEQ PDIG
 STA NFL
PDIG BIT NFL
 BMI PRD
 LDA JUST
 BPL NXDIG
PRD JSR COUT ;print
NXDIG DEX
 BPL LOAD0
 RTS


PRHEADER JSR PRINT
 HEX 8D
 ASC " Filename       Type    Bytes  Modified"
 HEX 8D8D00
 RTS

* Data Storage

NUMTBL DW 1,10,100,1000,10000

NH HEX 00
NL HEX 00
NFL HEX 00
JUST HEX 00

* Tables for displaying file type in ASCII
* Each entry in the TASC table corresponds
* to a hex entry in the TNUM table.
* (TASC entries are 3 bytes each)
* (TNUM entries are one hex byte each)

TNUM HEX 04,06,08,0B,0F,16,19,1A,1B,20
 HEX 5A,A0,B0,B1,B2,B3,B4,B5,B8,B9
 HEX BA,BB,BD,C0,C1,C7,C8,C9,CA,D5
 HEX D6,D7,D8,DB,E0,F0,F2,F9,FC,FD
 HEX FE,FF
 HEX 00 ;end of table marker

TASC ASC "TXT" ;$04
 ASC "BIN" ;$06
 ASC "FOT" ;$08
 ASC "WPF" ;$0B
 ASC "DIR" ;$0F
 ASC "PFS" ;$16
 ASC "ADB" ;$19
 ASC "AWP" ;$1A
 ASC "ASP" ;$1B
 ASC "TDM" ;$20
 ASC "CFG" ;$5A
 ASC "WP " ;$A0
 ASC "SRC" ;$B0
 ASC "OBJ" ;$B1
 ASC "LBR" ;$B2
 ASC "S16" ;$B3
 ASC "RTL" ;$B4
 ASC "EXE" ;$B5
 ASC "NDA" ;$B8
 ASC "CDA" ;$B9
 ASC "TOL" ;$BA
 ASC "DVR" ;$BB
 ASC "FST" ;$BD
 ASC "PNT" ;$C0
 ASC "PIC" ;$C1
 ASC "CDV" ;$C7
 ASC "FON" ;$C8
 ASC "FND" ;$C9
 ASC "ICN" ;$CA
 ASC "MUS" ;$D5
 ASC "INS" ;$D6
 ASC "MDI" ;$D7
 ASC "SND" ;$D8
 ASC "DBM" ;$DB
 ASC "LBR" ;$E0
 ASC "CMD" ;$F0
 ASC "MAC" ;$F2
 ASC "OS " ;$F9
 ASC "BAS" ;$FC
 ASC "VAR" ;$FD
 ASC "REL" ;$FE
 ASC "SYS" ;$FF

MONTHS ASC "JanFebMarAprMayJun"
 ASC "JulAugSepOctNovDec"

YEAR DFB 0
DAY DFB 0
MONTH DFB 0
ACCL DFB 0
ACCM DFB 0
ACCH DFB 0
MOD DFB 0
PRNTCNT DFB 0 ;counter for printing

TMPTYP DFB 0
ACTR DFB 0

THISBENTRY DFB 0 ;entry in this block
THISBLOCK DFB 0 ;block with dir
ENTRYLEN DFB 0 ;length of each dir entry
ENTPERBLK DFB 0 ;entries per block

HOWMANY DS 1
FILES DS 1

* ProDOS command parameter blocks

READPARMS
 DFB $04 ;number of parms
XRREFNUM DFB $00 ;refnum from open
 DA BUFFER ;pointer to buffer
REQAMT DW 512 ;amount to read
RETAMT DW $0000 ;amount actually read

GETPPARMS
 DFB $01 ;number of parms
 DA NAMEBUFFER ;pointer to buffer

 TR ON
BUFFER DS 512 ;enough for whole block
NAMEBUFFER DS 65 ;space for directory name
 TR OFF
