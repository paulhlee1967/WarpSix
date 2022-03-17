* X/YMODEM Send
* Public domain version 2.5.

* Entry point for Xmodem SEND command

SEND

 STZ YCOUNT

 LDA LFLAG ;copy orig. flags
 STA LSTART
 LDA KFLAG
 STA KSTART

 JSR DOFLAGS ;set SIZE based on flags

:NEXT LDA #<FILEBUF
 STA RBUFPTR
 LDA #>FILEBUF
 STA RBUFPTR+1 ;use our buffer

 LDA VPATH1 ;set pointer to filename
 STA OPATH
 LDA VPATH1+1
 STA OPATH+1

* Don't worry if file is empty; send anyway.

 JSR OPEN ;open the file
 BEQ :GOSEND

:ERROR JMP MLIERR

:GOSEND LDA OREFNUM ;get file's ref num
 STA RREFNUM ;save for READ
 STA GMREFNUM ;save for GET_MARK
 STA CLREFNUM ;save for CLOSE

 JSR PROMPT ;prompt downloader to initiate

YMODEM JSR INITVAR
 JSR CLEARV ;we're committed. Fall through.
 JSR DISPLAY0 ;set up bytes sent display

 LDA #60 ;one long (60 second) timeout
 STA TIMEOUT ;fall through

* SendINIT: Send-Init state

SENDINIT JSR GETBYTE ;wait for receiver to start
 BCC :NAK ;branch if we get a byte
:GOABORT JMP SNDABORT1 ;abort on timeout

:NAK CMP #NAK ;NAK?
 BEQ :GOPRO ;stay in checksum mode

:CNAK CMP #C ;C?
 BNE :CAN
 LDA #$FF ;set CRC mode
 STA CRCFLAG
 BNE :GOPRO ;always

:CAN CMP #CAN ;cancel?
 BNE :RETRY
 INC CANCOUNT
 LDA CANCOUNT
 CMP #2
 BGE :GOABORT

:RETRY DEC TRYCOUNT
 INC ERRCOUNT
 LDA TRYCOUNT
 BNE SENDINIT
 JMP SNDABORT

:GOPRO LDA #3 ;3 tries for ProDOS info
 STA TRYCOUNT
 LDA #10 ;10 second timeout
 STA TIMEOUT ;fall through

 JSR DELAYV ;added to avoid getting KL
 JSR CLEARV

* SENDPRO1: Send ProDOS1 state

SENDPRO1 ;set non-ProDOS as default
 STZ PFLAG ;but still try ProDOS mode
 STZ CANCOUNT
 LDA TRYPRO ;try ProDOS mode?
 BEQ :GOSEND ;if not, branch.
 BIT YFLAG ;Ymodem?
 BMI :GOSEND ;if so, skip handshake

:RETRY LDA #SSOH ;send ProDOS special header
 JSR MOUTV
 LDA #0 ;DOS 3.3 filetype (0 = ProDOS)
 JSR MOUTV
 EOR #$FF ;One's complement of byte 2
 JSR MOUTV

 JSR GETBYTE
 BCS :DORETRY

 CMP #ACK ;if ACK, get into ProDOS mode
 BNE :CAN
 LDA #$FF
 STA PFLAG
 BNE :GOSEND ;go to SENDDATA (always)

:CAN CMP #CAN ;CANcel?
 BNE :DORETRY
 INC CANCOUNT
 LDA CANCOUNT
 CMP #2
 BLT :DORETRY
:GOABORT JMP SNDABORT1

:DORETRY DEC TRYCOUNT ;didn't get ACK or CAN
 INC ERRCOUNT
 LDA TRYCOUNT
 BNE :RETRY
 ;if too many ProDOS tries
   ;try non-ProDOS mode.

:GOSEND LDA #60 ;one long (60 second) timeout
 STA TIMEOUT ;fall through to SENDDATA
 LDA #10 ;10 retries per packet if crc
 STA TRYCOUNT ;10 retries total if checksum

* Check if we are in Ymodem mode.

:YMODEM BIT YFLAG ;check flag
 BMI YBATCH
 JMP GOBIN ;if not, check Binary II.

** Ymodem batch READ parm list

YRPARMS DFB 4 ;parm count
YRREFNUM DS 1 ;refnum for our file
YRBUFPTR DA YPATHS ;bufr ptr
 DFB 255 ;byte request count
 DFB $00 ;high byte 0
YRXFRCNT DW $0000 ;xfer count

* Our batch file is already open. Read in
* the filenames.

YBATCH BIT CRCFLAG
 BPL :BAD
 LDA YCOUNT ;already in Ymodem mode?
 BEQ :GOOD
 JMP YCONT

:BAD JMP SNDABORT

:GOOD LDA OREFNUM ;copy our batch file's ref
 STA YRREFNUM

 ;zero out bytes read count
 STZ YRXFRCNT
 STZ YRXFRCNT+1

 JSR MLI ;read entire file at once
 DFB $CA
 DA YRPARMS
 BEQ :CLOSEB
 CMP #$4C ;end of file error?
 BEQ :CLOSEB
 PHA
 JSR CLOSE
 JSR CANCEL
 PLA
 JMP MLIERR

:CLOSEB JSR CLOSE ;close the batch file

 JSR DESTROY ;delete it.

* Now figure out YTOTAL, setting up YPATHS in
* the process.

* Y holds index into the YPATHS buffer
* X holds length of each filename

* Initialize our counters.

 STZ YCOUNT
 STZ YTOTAL
 STZ :DONEFLAG

 LDY #0
 LDX #0
:START STY :FIRST ;save offset of first byte
 INY  ;increment for first char
   ;of filename
:LOOP LDA YPATHS,Y ;get a byte
 CMP #'*' ;our end of file marker?
 BNE :CHECK
 LDA #$FF ;yes, end of file.
 STA :DONEFLAG ;flag it.
 BNE :FNAME ;always
:CHECK CMP #'!' ;end/beginning of fname?
 BEQ :FNAME
:INC INY  ;increment main index
 INX  ;increment fname index
 BRA :LOOP ;and continue reading fname
:FNAME STY :YTEMP ;save Y
 STX :FSTART ;length of last fname
 INC YTOTAL ;inc total # of files found
 LDY :FIRST ;load offset of last file len
 LDA :FSTART ;load length
 STA YPATHS,Y ;save length.
 LDA :DONEFLAG ;are we done?
 BNE YCONT ;yes!

* Reset X for another file, inc Y and continue.

 LDX #0
 LDY :YTEMP ;restore Y
 CLC  ;start new filename
 BCC :START

* local data area

:DONEFLAG DS 1
:FSTART DS 1
:FIRST DS 1
:YTEMP DS 1
:LENGTH DS 1

* YModem continue routine; is re-entrant.
* Increments counter for files, gets current
* filename and copies to VPATH1 so we can open it.

YCONT INC YCOUNT ;inc Ymodem file counter
 LDA YCOUNT
 CMP YTOTAL
 BLT :YGETNAME
 BEQ :YGETNAME
 BGE :YSETUP ;no more files to open

* local data area

:XTEMP DS 1
:LENGTH DS 1
:DOTCOUNT DS 1
:DOTPOS DS 1
:DOTFLAG DS 1
:DOTDONE DS 1

:YGETNAME LDY #0 ;start at beginning
 LDX #1 ;this will be first file

:CHECK CPX YCOUNT ;are we at the right file?
 BEQ :COPY ;if so, copy filename.

:SKIP   ;if not, skip this filename.
 LDA YPATHS,Y ;get length
 STA :LENGTH
 TYA  ;get current position
 CLC
 ADC :LENGTH ;add to length
 STA :LENGTH ;save result
 TAY  ;put in Y as index
 INY  ;add one.
 INX  ;inc file counter
 CLC  ;go to next file
 BCC :CHECK

:COPY LDA VPATH1 ;copy pointer
 STA PRTADR
 LDA VPATH1+1
 STA PRTADR+1
 TYA  ;copy our index into YPATHS
 TAX  ;into X.
 LDY #0 ;zero out Y
 LDA YPATHS,X ;get length
 STA :LENGTH
 STA (PRTADR),Y
 INX  ;point at 1st char of fname
 INY

:LOOP LDA YPATHS,X
 STA (PRTADR),Y
 INY
 INX
 CPY :LENGTH
 BLT :LOOP
 BEQ :LOOP

* Open current file and save OREFNUM everywhere.

:OPEN
 LDA VPATH1 ;set pointer to filename
 STA OPATH
 LDA VPATH1+1
 STA OPATH+1
 JSR OPEN ;open the file
 BEQ :GOYSET

:ERROR JMP MLIERR

:GOYSET LDA OREFNUM ;get file's ref num
 STA RREFNUM ;save for READ
 STA GMREFNUM ;save for GET_MARK
 STA CLREFNUM ;save for CLOSE

* Make sure packet is 128 byte size

:YSETUP
 STZ LFLAG
 STZ KFLAG
 JSR DOFLAGS ;set SIZE based on flags
 JSR PACKZERO ;zero current packet

* Is this the last packet? If so, just leave it
* full of nulls....!

 LDA YCOUNT
 CMP YTOTAL
 BLT :YINFO
 BEQ :YINFO
 JMP YSEND ;no file; send empty packet

* Get filename and convert each character to
* lower case and drop into PACKBUF.

:YINFO LDA VPATH1 ;copy pointer
 STA PRTADR
 LDA VPATH1+1
 STA PRTADR+1

 LDY #0
 STY :DOTCOUNT
 STY :DOTPOS
 STY :DOTFLAG
 STY :DOTDONE

 LDA (PRTADR),Y ;get filename length
 STA :LENGTH

* Find out how many dots in filename and pos'n of
* the last dot.

 TAY  ;length in Y
:DLOOP LDA (PRTADR),Y
 CMP #'.'
 BEQ :DOT
:DNEXT DEY
 BEQ :DOTEND
 BNE :DLOOP
:DOT INC :DOTCOUNT
 LDA :DOTCOUNT
 CMP #2
 BGE :DNEXT
 STY :DOTPOS
 CLC
 BCC :DNEXT
:DOTEND LDA :DOTCOUNT
 BEQ :MOVE
 SEC
 LDA :LENGTH
 SBC :DOTPOS
 CMP #3 ;dot at right place?
 BNE :MOVE
 LDA #$FF
 STA :DOTFLAG ;there IS an extension

* Move pathname to Ymodem header packet, converting
* to MS-DOS/Unix permissable filename.

:MOVE LDY #1
 LDX #0
:FLOOP LDA (PRTADR),Y ;get a byte from fname
 JSR DNSHIFT ;convert to lowercase

 BIT FIXNAME ;fix filename?
 BPL :STUFF ;no, just stuff it.

 BIT :DOTFLAG ;extension present?
 BMI :DOTCHK

* No extension present -- don't copy any dots

 CMP #'.' ;dot?
 BEQ :NEXTS

* Limit length to 8 characters.

 CPX #8 ;X holds destination index
 BGE :ZERO ;done if > 8
   ;otherwise, stuff it.

:STUFF STA PACKBUF,X ;save in PACKBUF
 INX
:NEXTS INY
 CPY :LENGTH ;check length
 BLT :FLOOP ;continue if not done.
 BEQ :FLOOP ;continue if last char.
 BGE :ZERO

* Extension present. Kill any dots in wrong pos'n.
* Limit non-extension portion of name to 8 chars.

:DOTCHK CMP #'.' ;dot?
 BEQ :CHK2

 BIT :DOTDONE ;worry about truncation?
 BMI :STUFF ;no, just stuff it.

 CPX #8 ;copied 8 chars yet?
 BLT :STUFF
 BGE :NEXTS ;skip

* Extension present & got dot. Is it the right one?

:CHK2 CPY :DOTPOS
 BNE :NEXTS ;skip it if wrong dot

* Got right dot. Set flag to indicate this.

 LDA #$FF
 STA :DOTDONE ;indicate we got dot
 LDA #'.' ;reload a dot
 JMP :STUFF ;stuff it.


* Stuff a zero after the filename and get EOF

:ZERO LDA #0
 STA PACKBUF,X ;zero after name
 INX
 STX :XTEMP ;save our position

 JSR EOFCALC ;get decimal EOF

 LDX :XTEMP
 LDY #0
:LLOOP LDA LENBUF,Y
 CMP #$A0 ;ignore leading spaces
 BEQ :SPACE
 AND #%01111111 ;clear high bit
 STA PACKBUF,X ;drop digit into PACKBUF

:NEXT INX
 INY
 CPY #9
 BLT :LLOOP
 BEQ :DOPRO

:SPACE INY
 CLC
 BCC :LLOOP

:DOPRO
 BIT TRYPRO
 BPL YSEND
 JSR YPRO

* Send Ymodem packet

YSEND
 STZ PACKNUM ;always 0 for Ymodem header
 STZ CANCOUNT
 LDA #10
 STA TRYCOUNT
 LDA #60 ;60 second timeout
 STA TIMEOUT ;fall through

:RETRY JSR SENDPAK ;send the data packet

:WAIT JSR GETBYTE
 BCC :CHECK ;branch if byte received.

:GOABORT JMP SNDABORT1 ;abort on timeout

:CHECK CMP #ACK
 BEQ :YDONE
 CMP #NAK
 BEQ :DORETRY
:CAN CMP #CAN ;cancel?
 BNE :WAIT
 INC CANCOUNT
 LDA CANCOUNT
 CMP #2
 BGE :GOABORT

:DORETRY DEC TRYCOUNT
 INC ERRCOUNT
 LDA TRYCOUNT
 BNE :RETRY
 JMP SNDABORT

:ERROR PHA
 JSR CLOSE
 JSR CANCEL
 PLA
 JMP MLIERR

:YDONE

* Check if Ymodem finished.
* If so, go to SNDDONE.

 LDA YCOUNT
 CMP YTOTAL
 BLT GOBIN
 BEQ GOBIN

:EXIT JMP SNDDONE

GOBIN INC PACKNUM ;(to $01)

 LDA LSTART
 STA LFLAG
 LDA KSTART
 STA KFLAG
 JSR DOFLAGS ;set SIZE based on flags

* Drop to CHKBIN2

* Check if Binary II mode enabled. If so, check if
* file already has Binary II header, and if not,
* create and send the Binary II header.

CHKBIN2 BIT BINARY2 ;check flag
 BPL SENDDATA

 ;temporarily
 STZ LFLAG
 STZ KFLAG
 JSR DOFLAGS ;set SIZE to 128 bytes
 JSR PACKCLR
 JSR READIT ;read 128 bytes

 LDA FILEBUF ;See if it's a Binary II
 CMP #$0A ;header or not.
 BNE :DOBIN ;if not, create one.
 LDA FILEBUF+1
 CMP #$47
 BNE :DOBIN
 LDA FILEBUF+2
 CMP #$4C
 BNE :DOBIN
 LDA FILEBUF+18
 CMP #$02
 BEQ :NOBIN ;header already here!

:DOBIN JSR SENDBIN2 ;create/send Binary II pak
   ;fall through to :NOBIN

:NOBIN LDA LSTART
 STA LFLAG
 LDA KSTART
 STA KFLAG
 JSR DOFLAGS ;restore flags and SIZE

 LDA #$CE ;make GETMARK SETMARK
 STA MARK
 STZ PCLOW
 STZ PCMID
 STZ PCHIGH
 JSR GETMARK ;Set_Mark to 0
 LDA #$CF ;restore byte
 STA MARK


* SENDDATA state, with :RETRY for retries.

SENDDATA LDA BADCNT ;did we have problems with
 BEQ :BEGIN ;last packet?
 ;if so, zero bad count (as
 STZ BADCNT ;we must have finally got
   ;a good one.
 JSR DROP ;change packet size flags
   ;(drop from 4K to 1K or
   ;from 1K to 128.)
   ;to avoid further errors
 JSR DOFLAGS ;ensure packet size modified

:BEGIN JSR PACKCLR ;fill packet buffer with ^Z's
 JSR READIT ;get packet of data from file
 STZ CANCOUNT
 BIT NOWFLAG ;got 0 bytes on READIT?
 BPL :KEYCHK
 JMP SENDEOT ;if so, end the transfer.

:KEYCHK LDA KEYBD ;check for sysop abort
 BPL :RETRY
 STA STROBE
 CMP #$9B ;ESC?
 BNE :RETRY
 JMP SNDABORT ;abort transfer!

:RETRY JSR SENDPAK ;send the packet
 BCC :WAIT
 JMP SNDABORT1

:WAIT JSR GETBYTE ;look for response
 BCC :CHK
 JMP SNDABORT1 ;abort transfer on timeout

:CHK CMP #ACK ;ACK?
 BEQ :NEXT ;get ready to send next packet

 CMP #NAK
 BEQ :DORETRY

 CMP #CAN ;CANcel?
 BNE :BAD
 INC CANCOUNT
 LDA CANCOUNT
 CMP #2
 BLT :WAIT
 BGE SNDABORT1

:BAD DEC TRYCOUNT ;dec trycount
 INC ERRCOUNT
 INC BADCNT ;inc bad count
 LDA TRYCOUNT ;check it
 BEQ SNDABORT
 STZ GOODCNT ;zero good count
 BRA :WAIT

:NEXT JSR GETMARK ;inc our packet counter
 JSR DISPLAY ;update bytes transferred display
 LDA CRCFLAG
 BEQ :NEXT1
 LDA #10 ;if crc mode, reset trycount
 STA TRYCOUNT

 INC GOODCNT ;inc good packet count

 LDA GOODCNT
 CMP #9 ;8 good packets sent?
 BLT :NEXT1

 LDA KSTART ;were we once in 1K mode?
 CMP KFLAG ;if different, step up!
 BNE :STEP
 LDA LSTART ;were we once in 4K mode?
 CMP LFLAG ;if the same, no.
 BEQ :NEXT1 ;if different, step up!

:STEP JSR STEPUP ;step up one packet size

:NEXT1 LDA ENDFLAG ;are we done yet?
 BNE SENDEOT ;if yes, branch.
 INC PACKNUM ;otherwise inc the packet num
 JMP SENDDATA ;and continue.

:DORETRY DEC TRYCOUNT ;dec trycount
 INC ERRCOUNT
 INC BADCNT ;inc bad count
 LDA TRYCOUNT ;check it
 BEQ SNDABORT
 STZ GOODCNT ;zero good count
 JMP :RETRY ;always retry until get ACK

* Send Abort state

SNDABORT JSR CANCEL
SNDABORT1 JSR CLOSE
 LDA #1 ;transfer failed.
 STA XERROR
 CLC
 RTS

* Send EOT state

SENDEOT LDA #10 ;we got this far, so reset it.
 STA TRYCOUNT
 STZ CANCOUNT

:EOT LDA #EOT ;end of text
 JSR MOUTV ;send it

 JSR GETBYTE
 BCS SNDABORT1 ;timeout aborts

 CMP #ACK
 BEQ SENDPRO2 ;got ACK

 CMP #CAN ;cancel
 BNE :DORETRY ;all else causes retry attempt
 INC CANCOUNT
 LDA CANCOUNT
 CMP #2
 BGE SNDABORT1

:DORETRY DEC TRYCOUNT
 INC ERRCOUNT
 LDA TRYCOUNT
 BNE :EOT
 BEQ SNDABORT

* Send ProDOS 2 state
* Check if ProDOS info transfer

SENDPRO2 LDA PFLAG ;ProDOS info transfer?
 BNE :NEXT
 JMP CHKYMODE ;done unless Ymodem batch
:NEXT LDA #10
 STA TIMEOUT

:GETSYN BIT YFLAG
 BPL :SYN
 JMP CHKYMODE

:SYN JSR GETBYTE ;get SYN
 BCS :GOABORT ;abort on timeout
 CMP #SYN
 BEQ SENDPRO3
 CMP #CAN
 BEQ :GOABORT
 BNE SENDPRO3

:GOABORT JMP SNDABORT1 ;abort on timeout

* Send ProDOS 3 state
* Send ETB and get NAK

SENDPRO3 LDA #ETB
 JSR MOUTV
 JSR GETBYTE
 BCC :CHECK
:GOABORT JMP SNDABORT1 ;abort on timeout
:CHECK CMP #NAK
 BEQ SENDPRO4
 CMP #CAN
 BEQ :GOABORT

 DEC TRYCOUNT
 INC ERRCOUNT
 LDA TRYCOUNT
 BNE SENDPRO3
 JMP SNDABORT

* Send ProDOS 4 state
* send final packet

SENDPRO4
 ;ensure we use 128 byte
 STZ LFLAG ;packet.
 STZ KFLAG
 JSR DOFLAGS
 JSR PACKZERO

 JSR GETINFO ;get_file_info
 BNE :ERROR

 LDA OREFNUM ;get file's ref num
 STA EOFPARMS+1 ;save for GETEOF
 JSR GETEOF ;and eof
 BNE :ERROR

* Modify access so destroy/rename/write/read enabled

 LDA FILEBUF+3 ;***** bug fix!
 ORA #%11000011 ;turn on those bits
 STA FILEBUF+3

 LDA #$D4
 STA FILEBUF+1 ;modify Get_Info parms
 LDA #$41 ;so they'll be recognized
 STA FILEBUF+2

 LDA #$AA ;set special packet #
 STA PACKNUM
 STZ CANCOUNT

:RETRY JSR SENDPAK ;send the data packet

 JSR GETBYTE
 BCC :CHECK ;branch if byte received.

:GOABORT JMP SNDABORT1 ;abort on timeout

:CHECK CMP #ACK
 BEQ CHKYMODE ;we're done this file!
 CMP #CAN
 BNE :DORETRY
 INC CANCOUNT
 LDA CANCOUNT
 CMP #2
 BGE :GOABORT

:DORETRY DEC TRYCOUNT
 INC ERRCOUNT
 LDA TRYCOUNT
 BNE :RETRY
 JMP SNDABORT

:ERROR PHA
 JSR CLOSE
 JSR CANCEL
 PLA
 JMP MLIERR

* Check if we are in Ymodem mode. If so,
* jump to Ymodem continue routine.

CHKYMODE
 JSR CLOSE ;close current file
 BIT YFLAG
 BPL SNDDONE
 JMP YMODEM

* Send Done state

SNDDONE JSR DISPLAYX
 JSR DELAYV ;pause for 1 second
 STZ XERROR flag as successful transfer
 CLC  ;inform BASIC that all is well
 RTS

* Subroutines

* SENDPAK: Send all bytes in PACKBUF, from byte 0.
* uses CRCFLAG to determine error checking mode.

SENDPAK BIT LFLAG ;4k mode?
 BPL :FLAG1
 LDA #SSTX
 BNE :SEND0 ;always
:FLAG1 BIT KFLAG ;1k mode?
 BPL :FLAG2
 LDA #STX
 BNE :SEND0 ;always
:FLAG2 LDA #SOH
:SEND0 JSR MOUTV

 LDA PACKNUM ;Packet number
 JSR MOUTV
 LDA PACKNUM
 EOR #$FF ;One's complement of packnum
 JSR MOUTV

 LDY #0 ;no offset
 STY CRC ;zero these before sending
 STY CRC+1
 STY CHECKSUM

 LDA #<PACKBUF ;set up pointer
 STA XPTR
 LDA #>PACKBUF
 STA XPTR+1

 JSR SETSTOP

* Loop below does all data bytes in the packet

:SEND LDA (XPTR),Y ;get a byte
 JSR MOUTV ;send it!
 BIT CRCFLAG
 BPL :CSUM0
 JSR CRCCALC
 BRA :DOINC
:CSUM0 JSR CSUMCALC

:DOINC INC XPTR ;always inc low byte
 LDA XPTR ;check if low byte 0
 BNE :CHECK ;if non zero, continue
 INC XPTR+1 ;if zero, inc high byte

:CHECK LDA STOP ;low byte of packbuf
 CMP XPTR
 BNE :SEND

 LDA STOP+1 ;load high byte
 CMP XPTR+1
 BNE :SEND

 BIT CRCFLAG ;all sent.
 BPL :CSUM ;if flag off, use checksum

 LDA CRC+1 ;and send it
 JSR MOUTV
 LDA CRC
 JSR MOUTV

:EXIT JSR CLEARV
 LDA DCDSTATE ;carrier present?
 BNE :NOGOOD

 CLC  ;return without error
 RTS

:CSUM LDA CHECKSUM ;and send it
 JSR MOUTV
 CLC
 BCC :EXIT

:NOGOOD SEC
 RTS

* READIT: Put from SIZE to 0 bytes in packet buffer.
* With automatic drop in packet size when reaching
* end of file, so that a minimum of padding is added.

READIT ;zero out bytes read count
 STZ RXFRCNT
 STZ RXFRCNT+1

 LDA SIZE ;get bytes to fill packet
 STA RREQCNT
 LDA SIZE+1
 STA RREQCNT+1

 JSR MLI ;if not, get some data
 DFB $CA ;read
 DA RPARMS
 BEQ :WASREAD ;any error?

 CMP #$4C ;end of file? (0 bytes read)
 BNE :ERROR ;if not, was real error
 LDA #$FF
 STA NOWFLAG ;got 0 bytes from file.
 BNE :FEND ;always

:WASREAD LDA RXFRCNT ;did we hit eof?
 CMP SIZE
 BNE :DROP ;if so, drop.
 LDA RXFRCNT+1
 CMP SIZE+1
 BNE :DROP ;drop
:OK RTS ;if not, okay.

:DROP BIT LFLAG ;if 4 or 1k mode, drop
 BMI :DODROP ;to smaller packet size.
 BIT KFLAG
 BPL :FEND ;if not, eof is okay.

:DODROP JSR DROP

:REDO LDA #$CE ;re-read with smaller SIZE
 STA MARK
 JSR GETMARK ;Set_Mark to previous
 LDA #$CF ;restore byte
 STA MARK
 BNE READIT ;now re-read (always)

:FEND LDA #$FF ;eof reached, set flag
 STA ENDFLAG
 RTS

:ERROR PHA ;save MLI error
 JSR CLOSE ;close
 JSR CANCEL ;cancel transfer
 PLA ;restore MLI error
 JMP MLIERR

* Send Binary II state
* Creates Binary II initial packet and sends it.

SENDBIN2 JSR PACKZERO ;zero packet contents!

 JSR GETINFO ;get_file_info
 BEQ :EOF
 JMP :ERROR

:EOF LDA OREFNUM ;get file's ref num
 STA EOFPARMS+1 ;save for GETEOF
 JSR GETEOF ;and eof
 BEQ :SIG
 JMP :ERROR

:SIG LDA #$47
 STA FILEBUF+1 ;modify Get_Info parms
 LDA #$4C ;so they'll be recognized
 STA FILEBUF+2

 ;zero refnum in EOF
 STZ FILEBUF+19

* Modify access so destroy/rename/write/read enabled

 LDA FILEBUF+3
 ORA #%11000011 ;turn on those bits
 STA FILEBUF+3

 LDA #$01
 STA FILEBUF+126 ;version number 01

 LDA FILEBUF+8 ;copy blocks used
 STA FILEBUF+117
 LDA FILEBUF+9
 STA FILEBUF+118

* Note: leaves number of files to follow byte at 0.

* Get Filename for Binary II send

 LDA VPATH1 ;copy pointer
 STA PRTADR
 LDA VPATH1+1
 STA PRTADR+1

 LDY #0 ;set index var
 LDA (PRTADR),Y ;get pathname length

 TAY
 STA :OLDLEN ;save length
 INC :OLDLEN ;use length + 1 later

 LDX #0 ;for filename length
:LOOP LDA (PRTADR),Y ;get a character
 CMP #'/' ;ProDOS separator?
 BEQ :CHOP ;if so, chop off
 INX  ;inc filename length
 DEY  ;dec pointer
 BNE :LOOP ;branch if not done.

:CHOP TXA  ;get length
 STA FILEBUF+23 ;put in buffer
 INY  ;inc pointer to 1st char

 LDX #1
:COPY LDA (PRTADR),Y ;get a character
 STA FILEBUF+23,X ;copy for Binary II
 INX
 INY  ;inc pointer
 CPY :OLDLEN ;compare to old len + 1
 BNE :COPY

 STZ CANCOUNT

:RETRY JSR SENDPAK ;send the data packet

 JSR GETBYTE
 BCC :CHECK ;branch if byte received.

:GOABORT PLA  ;nested rtn; do a POP.
 PLA
 JMP SNDABORT1 ;abort on timeout

:CHECK CMP #ACK
 BEQ :BINDONE
 CMP #CAN
 BNE :DORETRY
 INC CANCOUNT
 LDA CANCOUNT
 CMP #2
 BGE :GOABORT

:DORETRY DEC TRYCOUNT
 INC ERRCOUNT
 LDA TRYCOUNT
 BNE :RETRY
 PLA
 PLA
 JMP SNDABORT

:ERROR TAX  ;save error code
 PLA
 PLA
 TXA
 PHA
 JSR CLOSE
 JSR CANCEL
 PLA
 JMP MLIERR

:BINDONE INC PACKNUM
 RTS
:OLDLEN DS 1

* DROP from 4K to 1K or 1K to 128

DROP BIT LFLAG ;in 4K mode?
 BPL :DROP1 ;if not, check 1K mode

:DROP0 ;drop down to 1K mode
 STZ LFLAG
 STZ SIZE ;set SIZE low byte
 LDA #$04
 STA SIZE+1 ;set SIZE high byte
 LDA #$FF
 STA KFLAG ;set 1K flag
 RTS

:DROP1 BIT KFLAG ;in 1K mode?
 BPL :END ;if not, all okay.
 ;drop into 128 mode
 STZ KFLAG
 STZ SIZE+1 ;set SIZE high byte
 LDA #$80
 STA SIZE ;set SIZE low byte
:END RTS

* STEPUP a packet size

STEPUP BIT LFLAG ;already in 4k mode?
 BMI :END
 BIT KFLAG ;in 1K mode?
 BMI :KTOL ;if so, go to 4K

:STEP0 ;step-up to 1K mode
 STZ LFLAG
 STZ SIZE ;set SIZE low byte
 LDA #$04
 STA SIZE+1 ;set SIZE high byte
 LDA #$FF
 STA KFLAG ;set 1K flag

 ;reset good count so we
 STZ GOODCNT ;don't jump to 4K on next
 RTS  ;successful packet.

:KTOL ;step up to 4K mode
 STZ KFLAG
 STZ SIZE
 LDA #$10
 STA SIZE+1
 LDA #$FF
 STA LFLAG
 ;for consistency only
 STZ GOODCNT
:END RTS

* GET_INFO on the file

GETINFO LDA VPATH1 ;pathname pointer
 STA GETPARMS+1
 LDA VPATH1+1
 STA GETPARMS+2

GETINFO1 LDA #$0A ;parm count
 STA GETPARMS
 LDY #3
 LDA #0
:LOOP STA GETPARMS,Y ;zero the parm table
 INY
 CPY #$12
 BLT :LOOP

 JSR MLI
 DFB $C4 ;GET_FILE_INFO
 DA GETPARMS ;point to packet buffer
 RTS

DOFLAGS BIT LFLAG ;4k mode?
 BPL :FLAG1
 LDA #$10 ;set SIZE for 4K
 STA SIZE+1
 STZ SIZE
 BRA :NEXT ;always

:FLAG1 BIT KFLAG ;1k mode?
 BPL :FLAG2
 LDA #$04 ;set SIZE for 1K
 STA SIZE+1
 STZ SIZE
 BRA :NEXT ;always

:FLAG2 LDA #$80 ;set SIZE
 STA SIZE
 STZ SIZE+1
:NEXT RTS

* Routine to get file's EOF and convert to decimal
* File must be open. Leaves decimal length in LENBUF,
* with possible leading spaces.

EOFCALC LDA OREFNUM ;get file's ref num
 STA :EOFPARMS+1 ;save for GETEOF

 LDA #2 ;set up parm list
 STA :EOFPARMS ;parm count
 STZ :EOFPARMS+2 ;low byte
 STZ :EOFPARMS+3 ;mid byte
 STZ :EOFPARMS+4 ;high byte

 JSR MLI
 DFB $D1 ;get_eof
 DA :EOFPARMS ;point to location in buffer

 BEQ :PREP

* Abort on error

 JMP SNDABORT

* Prepare for hex to decimal conversion

:PREP LDA #0
 STA ACCH ;ensure high byte zero
 LDA #" "
 LDX #7
:SPACED STA LENBUF,X ;fill buffer with spaces
 DEX
 BNE :SPACED
 STA LENBUF

 LDA :EOFPARMS+4 ;high byte
 STA ACCH

 LDA :EOFPARMS+3
 TAX ;medium byte in X

 LDA :EOFPARMS+2 ;low byte
 LDY #7 ;# of chars to print -1
 JSR HEXDEC

* Value is now in LENBUF...

 RTS

* Parameter list for our GETEOF call

:EOFPARMS DS 5
 LST OFF

INITVAR ;set up flags/vars
 STZ XERROR ;error code for BASIC, 0= okay
 STZ CRCFLAG ;CRC mode flag, default off.
 STZ ENDFLAG ;end of file/last block flag
 STZ NOWFLAG
 STZ GOODCNT
 STZ CANCOUNT
 STZ PACKNUM
 STZ ERRCOUNT

 STZ PCLOW
 STZ PCMID
 STZ PCHIGH

 LDA #10 ;10 errors maximum
 STA TRYCOUNT ;global error counter

* Load value to timeout in 60 seconds

 LDA #60
 STA TIMEOUT ;about 60 seconds
 RTS

* Get file info and eof info into Ymodem packet zero

YPRO LDA #$0A ;Get_File_Info parm count
 STA PACKBUF+66
 LDA VPATH1 ;pathname pointer
 STA PACKBUF+67
 LDA VPATH1+1
 STA PACKBUF+68
 JSR MLI
 DFB $C4 ;Get_File_Info
 DA PACKBUF+66

* Modify access so destroy/rename/write/read enabled

 LDA PACKBUF+69
 ORA #%11000011 ;turn on those bits
 STA PACKBUF+69

* Ymodem ProDOS Block Zero Layout

* comp_id db $1d ; byte+64 = $1d (ymodem prodos id byte)
* os_type db 0 ; byte+65 = $00 (never actually used)
* fl_parm db 0 ; parm_len (should be $0a)
* dw 0 ; filename_pointer (no assigned value)
* fl_info ds 15 ; get_file_info results
* fl_eof db 2 ; parm_len (should be 2)
* db 0 ; ref_num (no assigned value)
* fl_length ds 3 ; get_eof result
* ds 128-*,0 ; rest of block is zeroes

* Add ID bytes for recognition by Ymodem ProDOS

 LDA #$1D
 STA PACKBUF+64
 LDA #$47
 STA PACKBUF+65
 LDA #'G'
 STA PACKBUF+67
 LDA #'L'
 STA PACKBUF+68

* Put EOF info into Ymodem packet zero

 LDA #2 ;set up parm list
 STA PACKBUF+84 ;parm count
 LDA OREFNUM
 STA PACKBUF+85 ;file refnum
 STZ PACKBUF+86 ;low byte
 STZ PACKBUF+87 ;mid byte
 STZ PACKBUF+88 ;high byte

 JSR MLI
 DFB $D1 ;get_eof
 DA PACKBUF+84 ;point to location in buffer

 ;zero out file refnum
 STZ PACKBUF+85

 RTS
