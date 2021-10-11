 LST OFF

BEGIN = $8D00 ;we need up to $99FF

 ORG BEGIN-$300-$400-$500
 DSK /HD1/WARP6/BBS/COPY

********************************************************
*                                                      *
*        Name: COPY                                    *
*                                                      *
* Description: Allows you to copy all but directory    *
*   files from anyplace to anyplace, changing the      *
*   name if desired.  Works only under ProDos.         *
*   Cannot copy from disk to disk with single drive    *
*   system.                                            *
*                                                      *
*   COPY source pathname,destination pathname          *
*                                                      *
*   This also functions as a DOS command in a BASIC    *
*   program in the usual way.                          *
*                                                      *
*  Programmer: Robert M. Delaney                       *
*              248-D Glandore Dr.                      *
*              Manchester, MO  63021                   *
*              (314) 394-7745                          *
*                                                      *
*        Date: March, 1985 (rev. August 17, 1986)      *
*                                                      *
*       Modified for Warp Six BBS so it reports a      *
*       duplicate filename error when trying to        *
*       copy to an existing file. Also will copy       *
*       empty files.                                   *
*                                                      *
*        Date: August 8, 1991                          *
*                                                      *
*********************************************************
*
*
* Some of these Global Page names are used in "Beneath
* Apple ProDos" by Don Worth and Pieter Lechner,
* published by Quality Software 1984.  Also I have
* adapted some of their techniques.
*
* fixed locations we need
*

PTR EQU $06 work space pointer
PTR1 EQU $08
PTR2 EQU $1A
PTR3 EQU $1C

ARREND EQU $6D pointer to end of array space
STRST EQU $6F pointer to start of string space
HIMEM EQU $73 HIMEM (start of GP buffer)
IN EQU $200 input line buffer
MLI EQU $BF00 machine language interface
KBD EQU $C000 keyboard latch
KBDSTB EQU $C010 keyboard clear strobe
COUT EQU $FDED monitor print vector
CALLX EQU $BCA8
SYSBCALL EQU $BE8B
SYSCTBL EQU $B85F
DATE EQU $BF90
TIME EQU $BF92
TIMEVEC EQU $BF06
*
* selected things from the BI global page
*
 DUM $BE00 ;dummy section is not compiled

* start of BI global page
*
BIENTRY JMP $0000 warm entry into ProDos BI
DOSCMD JMP $0000 command executer
EXTCMD JMP $0000 external command vector
ERROUT JMP $0000 exit with error
PRNTERR JMP $0000 print error message
ERRCODE DFB 0 error code
*
 ORG $BE50
XTADDR DW $0000 exec addr of external cmd
XLEN DFB 0 length of cmd string -1
XCNUM DFB 0 BI command number
*
* PBITS/FBITS bit definition
*
FN1 EQU $01 file name expected
FN2 EQU $02 file name #2 expected
T EQU $04 file type
CRFLG EQU $08 create allowed
FNOPT EQU $10 filename is optional
RRUN EQU $20 command only valid during program
SLOT EQU $40 no parameters to be processed
PFIX EQU $80 prefix needs fetching,
*                           pathname optional
PBITS DW 0 allowed parameters bits
*
* PBITS+1/FBITS+1 bit definition
*
R EQU $01 record
F EQU $02 field
SD EQU $04 slot/drive permitted
LINE EQU $08 '@' line number
L EQU $10 length
E EQU $20 end address
B EQU $40 byte
AD EQU $80 address
FBITS DW 0 parameters found bits
*
*   new origin
*
 ORG $BE3C
*
DFSLOT DFB $00
DFDRV DFB $00
*
*   new origin
*
 ORG $BE6C
*
VPATH1 DW $0000 addr of PATHNAME 1 buffer
VPATH2 DW $0000 addr of PATHNAME 2 buffer
*
GOSYS EQU * MLI call handler
*
 ORG $BEA0
*
SCREATE EQU *
*
 DFB $07 parm count = 7
 DW $0000 pointer to pathname
CRACESS DFB $C3 =$C1 if directory CREATE
CRFILID DFB $00
CRAUXID DW $0000
CRFKIND DFB $00
CRDATE DW $0000
CRTIME DW $0000
*
SSGPRFX EQU *
*
SDSTROY DFB $01
 DW $0000 this call requires no modification
*
SRENAME EQU *
 DFB $02 parm count = 2
 DW $0000 source filename pointer
 DW $0000 target filename pointer
*
SSGINFO DFB $00 P.COUNT=7 if SET.FILE.INFO
*                         P.COUNT=A if GET.FILE.INFO
 DW $0000
FIACESS DFB $00 access used by lock/unlock
FIFILID DFB $00 file ID is type specifier
FIAUXID DW $0000 AUX.ID used for load addr
*                              and record length
FIFKIND DFB $00 identifies trees vs directories
FIBLOKS DW $0000 used by cat commands for root dir
FIMDATE DW $0000 modification date & time
 DW $0000 should always be zeroed before call
 DW $0000 create date and time ignored
 DW $0000
*
SONLINE EQU *
SSETMRK EQU *
SGETMRK EQU *
SSETEOF EQU *
SGETEOF EQU *
SSETBUF EQU *
SGETBUF EQU *
 DFB $02 PARM. COUNT = 2
SBUFREF EQU *
SREFNUM EQU *
SUNITNUM EQU *
 DFB $00 unit or reference number
SDATPTR EQU *
SMARK EQU *
SEOF EQU *
SBUFADR EQU *
 DFB $00 some calls only use 2 bytes
 DFB $00 MRK & EOF use 3 bytes
 DFB $00
*
SOPEN DFB $03 OPEN parameter list
*
 DW $0000
OSYSBUF DW $0000 buffer addr
OREFNUM DFB $00 ref num returned
*
SNEWLIN DFB $03
NEWLREF DFB $00 reference number
NLINENBL DFB $7F Newline character is always CR
 DFB $00 both $00 and $80 are recognized
*
SREAD EQU * READ/WRITE parm list
SWRITE EQU *
*
 DFB $04 PARM COUNT = 4
RWRFNUM DFB $00 refnum
RWDATA DW $0000 buffer addr
RWCOUNT DW $0000 request length
RWTRANS DW $0000 true length
*
SCLOSE EQU * CLOSE/FLUSH parm list
SFLUSH EQU *
 DFB $01 PARM COUNT = 1
CFRFNUM DFB $00 refnum
*
 ORG $BEF5
GETBUFR JMP $0000 allocate BI buffer
FREBUFR JMP $0000 free all buffers
*
 DEND
*
*   this part is executed on a BRUN, it
*   relocates the resident part of code to
*   the top of memory.
*
COPY

*
* Main Program
*
*   when command has been passed to the BI,
*   and after finishing parsing, the following
*   code is called by the BI, so it should pass
*   control back by an RTS
*
*   0. we need to allocate buffers
*
*   first we save for later restoration
*

* LDA TIMEVEC
* STA VECSAVE

 LDA SSGPRFX+1
 STA SAVESSGP
 LDA SSGPRFX+2
 STA SAVESSGP+1
 LDX ARREND+1 get HI byte of address of
*                                       array end
 INX  add 1 to form HI byte of
*                              address of data buffer
 LDA STRST+1 get HI byte of address
*                                   of string start
 SEC
 SBC #4 subtract 4 to form HI byte
*                                  of address of dest.
*                                  I/O buf.
 STA DSYSBUF+1 init HI buf addr. for
*                                    DOPEN of dest. file
 SEC
 SBC #1
 STA SBUFADR+1 init HI buf addr. for
*                                    ONLINE and GET.PREFIX
 STA SSGPRFX+2
 STA PTR+1
 CPX SBUFADR+1 test if room for data buffer
 BCS BUFERR no buffer room, abort
 STX RWDATA+1 init HI data buf. addr. for
*                                         SREAD of source file
 LDX #0
 STX DSYSBUF init all LO address bytes
 STX RWDATA
 STX RWCOUNT
 STX SCOUNT
 STX OSYSBUF
 STX SBUFADR
 STX SSGPRFX+1
 STX PTR
 SEC
 SBC RWDATA+1 form data buffer length in
*                                        $100 byte units
 STA RWCOUNT+1 now have given no. of bytes
*                                          to be read in a chunk
 STA SCOUNT+1
 LDA HIMEM+1
 STA OSYSBUF+1 init HI buf addr.
*                                for SOPEN of source file
 BNE PREF always taken
*
*   a good place for BUFERR
*
BUFERR LDA #11 ;no buffers available error
 STA CALLA
 JMP COPYERR
*
*   prepare buffer pointers
*
PREF LDA VPATH1
 STA PTR1
 LDA VPATH1+1
 STA PTR1+1
 LDA VPATH2
 STA PTR2
 LDA VPATH2+1
 STA PTR2+1
*
*   we must see if any prefix was set
*
 LDA #$C7 MLI: GET_PREFIX
 JSR GOSYS
 BEQ PREFA
 JMP COPYERRA
PREFA LDY #0
 LDA (PTR),Y
 BNE FULLPATH
*
*   now we must take care of prefixes
*
*   get current prefix if prefix not set
*
 LDA DFSLOT default slot
 ASL A
 ASL A
 ASL A
 ASL A put slot no. in high nibble
 LDX DFDRV default drive
 CPX #1 drive 1?
 BEQ PREF1 yes
 ORA #$80 no, put 1 as MSBit
PREF1 STA SUNITNUM get ready for ONLINE command
 LDA #$C5 MLI: ONLINE
 JSR GOSYS
 BCC PREF2
 JMP COPYERR
PREF2 LDY #0
 LDA (PTR),Y
 AND #$0F get length
 BNE PREF3
 LDA #$08 I/O error
 JMP COPYERR
PREF3 STA (PTR),Y put length as 0th byte
*
*   add / to front and end of prefix
*
 TAY
 INY
 LDA #$2F prepare to put / at end
 BNE PREF5
PREF4 LDA (PTR),Y
PREF5 INY
 STA (PTR),Y
 DEY
 DEY
 BNE PREF4
 LDA (PTR),Y increase length by 2
 CLC
 ADC #2
 STA (PTR),Y
 LDA #$2F
 INY
 STA (PTR),Y add / to name
*
*   we make sure of full path names
*
FULLPATH LDY #1
 LDA (PTR1),Y
 CMP #$2F is it / ?
 BEQ PREF8 yes
*
*   we must move source name to right
*   to make room for prefix
*
 DEY
 LDA (PTR1),Y get source name length
 CLC
 ADC (PTR),Y add prefix length
 STA (PTR1),Y adjust length byte
 LDA PTR1
 CLC
 ADC (PTR),Y
 STA PTR3
 LDA PTR1+1
 ADC #0
 STA PTR3+1 PTR3 points to rightmost
*                                    byte of new loc.
 LDA (PTR1),Y source name length
 TAY
PREF6 LDA (PTR1),Y move name to the right
 STA (PTR3),Y
 DEY
 BNE PREF6
 LDA (PTR),Y prefix name length
 TAY
PREF7 LDA (PTR),Y
 STA (PTR1),Y
 DEY
 BNE PREF7
PREF8 LDY #1
 LDA (PTR2),Y
 CMP #$2F is it / ?
 BEQ CMPNAMES
*
*   we must move dest. name to right
*   to make room for prefix
*
 DEY
 LDA (PTR2),Y get dest. name length
 CLC
 ADC (PTR),Y add prefix length
 STA (PTR2),Y adjust length byte
 LDA PTR2
 CLC
 ADC (PTR),Y
 STA PTR3
 LDA PTR2+1
 ADC #0
 STA PTR3+1 PTR3 points to rightmost
*                                    byte of new loc.
 LDA (PTR2),Y dest. name length
 TAY
PREF9 LDA (PTR2),Y move name to the right
 STA (PTR3),Y
 DEY
 BNE PREF9
 LDA (PTR),Y prefix name length
 TAY
PREF10 LDA (PTR),Y
 STA (PTR2),Y
 DEY
 BNE PREF10
*
*   now we must compare names
*
CMPNAMES LDY #0
 LDA (PTR1),Y
 CMP (PTR2),Y compare lengths
 BNE SOURCEXS can't be same name
 TAY
CMP1 LDA (PTR1),Y
 CMP (PTR2),Y
 BNE SOURCEXS can't be same name
 DEY
 BNE CMP1
*
*   we have same names - error
*
 LDA #11 invalid option error
 JMP COPYERR
*
*   1. find if source file exists,
*      if not, error.
*
SOURCEXS LDA #$0A
 STA SSGINFO want to GET_FILE_INFO
 LDA #0
 STA FIMDATE    zero mod. date & time
 STA FIMDATE+1
 STA FIMDATE+2
 STA FIMDATE+3
 LDA #$C4 MLI: GET_FILE_INFO
 JSR GOSYS do it for source file
 BCS COPYERR error?
*
*   save source info
*
 LDA FIACESS
 STA DIACESS
 LDA FIFILID
 STA DIFILID
 LDA FIAUXID
 STA DIAUXID
 LDA FIAUXID+1
 STA DIAUXID+1
*
*   2. check if source file is a directory,
*      if so exit with FILE TYPE
*      MISMATCH error.
*
 LDA FIFILID get file type.
 CMP #$0F directory file?
 BNE OPENSRC no, go to 3.
 LDA #$0D File Type Mismatch error #
 SEC
 BCS COPYERR
*
*   3. open source file
*
OPENSRC LDA #$C8 MLI: OPEN
 JSR GOSYS open the source file
 BCS COPYERR
 LDA OREFNUM copy REF NUM
 STA RWRFNUM to READ list for the 1st
*                                     read
 STA SRFNUM save ref. no. for source
*
*   4. read source file
*
 LDA #$CA MLI: READ
 JSR GOSYS read 1st chunk of source
*                                   file
 BCC DEXIST no error
 CMP #$05 EOF error?
 BEQ DEXIST still copy even if empty
 JMP COPYERR1 unknown error
*
*   all exits occur in the following
*
GOODRTS LDA SAVESSGP
 STA SSGPRFX+1
 LDA SAVESSGP+1
 STA SSGPRFX+2
*
* LDA VECSAVE restore time vector
* STA TIMEVEC
*
 CLC
 RTS
*
*   here to exit with error
*
COPYERR STA CALLA save error code
 LDA SAVESSGP
 STA SSGPRFX+1
 LDA SAVESSGP+1
 STA SSGPRFX+2
*
* LDA VECSAVE restore time vector
* STA TIMEVEC
*
 LDA CALLA restore error code
COPYERRA SEC
 JMP ERROUT
*
*   5. Check if destination file exists,
*      if not, go to 11.
*
*   move dest. name in place of source name
*
DEXIST LDY #0
 LDA (PTR2),Y get dest. name length
 STA (PTR1),Y and move it to name1 buffer
 TAY
DEXISTA LDA (PTR2),Y
 STA (PTR1),Y
 DEY
 BNE DEXISTA
 LDA #$0A name is moved
 STA SSGINFO want GET_FILE_INFO for dest.
 LDA #0
 STA FIMDATE
 STA FIMDATE+1
 STA FIMDATE+2
 STA FIMDATE+3
 LDA #$C4 MLI: GET_FILE_INFO
 JSR GOSYS do it for destination file
 CMP #$07 does dest. file exist?
 BNE DEXIST1 yes
 JMP CRDEST no
DEXIST1 LDA #19 Duplicate filename error
*                            Applesoft code #
 JMP COPYERR1
*
*   11. create destination file
*
CRDEST LDA DIACESS
 ORA #$C3 unlock
 STA CRACESS
 LDA DIFILID
 STA CRFILID
 LDA DIAUXID
 STA CRAUXID
 LDA DIAUXID+1
 STA CRAUXID+1
*
* Force Date/Time to our values
*
* LDA #$60 plug in an 'RTS'
* STA TIMEVEC
*
* LDA OURDATE low byte of date
* STA DATE
* LDA OURDATE+1 high byte of date
* STA DATE+1
* LDA OURTIME low byte of time
* STA TIME
* LDA OURTIME+1 high byte of time
* STA TIME+1
*
 LDA #1
 STA CRFKIND standard seedling file at
*                                      creation
 LDA #$C0 MLI: CREATE
 JSR GOSYS do it for dest. file
 BCC OPENDES
 JMP COPYERR1
*
*   12. open destination file
*
*   we need to change to dest. buffer
*
OPENDES LDA DSYSBUF
 STA OSYSBUF
 LDA DSYSBUF+1
 STA OSYSBUF+1
 LDA #$C8 MLI: OPEN
 JSR GOSYS open destination file
 BCC OPENDES1
 JMP COPYERR1
OPENDES1 LDA OREFNUM
 STA CFRFNUM for CLOSE
 STA SREFNUM for SET EOF
 STA DREFNUM and save dest. ref. no.
*
*   13. copy source file to destination file
*
*   we first write (we read in 4.)
*
COPYSD LDA DREFNUM get dest. ref. no.
 STA RWRFNUM and store
 LDA RWTRANS transfer actual length
 STA RWCOUNT for write
 LDA RWTRANS+1
 STA RWCOUNT+1
 LDA #$CB MLI: WRITE
 JSR GOSYS write a chunk of dest. file
 BCS COPYERR2
*
*   then read
*
 LDA SRFNUM get source ref. no.
 STA RWRFNUM
 LDA SCOUNT
 STA RWCOUNT
 LDA SCOUNT+1
 STA RWCOUNT+1
 LDA #$CA MLI: READ
 JSR GOSYS read a chunk of source file
 BCC COPYSD no error; keep copying!
 CMP #5 EOF error?
 BNE COPYERR2 no, real error
*
*   14. now we clean up
*
 LDA #$CF MLI:GET_MARK
 JSR GOSYS gets dest. mark
 BCS COPYERR2
 LDA #$D0 MLI: SET_EOF for dest. file
 JSR GOSYS release any unused blocks
*                                of dest. file
 BCS COPYERR2
 LDA DIACESS get original source status
 STA FIACESS put dest. in same status
*                                as source
 LDA DIFILID
 STA FIFILID
 LDA DIAUXID
 STA FIAUXID
 LDA DIAUXID+1
 STA FIAUXID+1
 LDA #$07
 STA SSGINFO parameter no. for SET
 LDA #$C3 MLI: SET_FILE_INFO
 JSR GOSYS do it for dest. file
 BCS COPYERR2
*
*   close files
*
 LDA #$CC MLI: CLOSE
 JSR GOSYS close dest. file
 BCS COPYERR2
GOODRTS1 LDA SRFNUM here if user says
*                                    no on copy.
 STA CFRFNUM prepare to close source
*                                    file
 LDA #$CC MLI: CLOSE
 JSR GOSYS close source file
*
 JMP GOODRTS done!
*
*   all done
*
*   a new COPYERR to close source file
*
COPYERR1 STA CALLA
 LDA SRFNUM
 STA CFRFNUM
 LDA #$CC MLI: CLOSE
 JSR GOSYS close source file
 LDA CALLA
 JMP COPYERR
*
*   COPYERR2 for a bad error, close files
*   and give warning
*
COPYERR2 STA CALLA save error code
 LDA SRFNUM
 STA CFRFNUM
 LDA #$CC MLI:CLOSE
 JSR GOSYS close source file
 LDA DREFNUM
 STA CFRFNUM
 LDA #$CC MLI:CLOSE
 JSR GOSYS close destination file

 LDA CALLA restore error code
 JMP COPYERR exit through error routine
*
*   end the program for the relocater
*
 DS \
*
*   some necessary data and locations
*
CALLA DFB $00
SCOUNT DW $0000
SAVESSGP DW $0000
DSYSBUF DW $0000
SRFNUM DFB $00
DREFNUM DFB $00
DIACESS DFB $00
DIFILID DFB $00
DIAUXID DW $0000

*VECSAVE DFB $00
*OURDATE DW $B714 August 20, 1991
*OURTIME DW $011E 01:30 am
