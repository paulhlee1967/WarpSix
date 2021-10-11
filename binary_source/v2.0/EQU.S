* Public domain version 2.0

 ORG BEGIN ;we need up to $99FF.

* Firmware Addresses

KEYBD = $C000
STROBE = $C010
OAKEY = $C061
C3COUT1 = $C307
BELL = $FBDD
HOME = $FC58
CLREOL = $FC9C
CROUT = $FD8E
PRBYTE = $FDDA
COUT = $FDED
OURCH = $57B
OURCV = $5FB
WNDWDTH = $21

VBLINT = $C019

* 6551 Addresses in Super Serial Card

DATAREG = $C088
STATREG = $C089
CMDREG = $C08A
CTRLREG = $C08B

* Apple IIgs Z8530 registers and constants

GSCMDB = $C038
GSCMDA = $C039
GSDATAB = $C03A

GSDATAA = $C03B

WR11A = %11010000 ;init wr11 in Ch A
WR11B = %01010000 ;init wr11 in Ch B
   ;crystal not used by Ch B
   ;3.6864MHz external crystal
   ;Rx/Tx clock source = BRG
   ;TRxC is an input (tied to cts)
   ;bits 1 and 0 insignificant

RESETCHA = %11001010 ;constant to reset Ch A
RESETCHB = %01001010 ;constant to reset Ch B

* ProDOS & Basic.System

HIMEM = $73

MLI = $BF00
DATE = $BF90
TIME = $BF92
MACHID = $BF98

ERROUT = $BE09
XTRNADDR = $BE50
XLEN = $BE52
XCNUM = $BE53
PBITS = $BE54
VPATH1 = $BE6C
BADCALL = $BE8B
CMDADR = $BF9C

* AppleSoft BASIC

VARTAB = $69

* Our Buffers

INBUF = $200
MBUF = BEGIN-$100
LINBUF = BEGIN-$200
WWBUF = BEGIN-$300
IOBUF = WWBUF-$400

* Zero page locations -- used internally only

XPTR = $FA ;pointer for Xmodem routines

* Xmodem dependencies

SENDV = BEGIN-$2F00-$300-$400 ;for XMODEM
RECEIVEV = BEGIN-$2F00-$300-$400+$04 ;for XMODEM
COPYV = BEGIN-$300-$400-$500
