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

* Warp Six BBS PD version 2.5.
* Created by Jim Ferr.

:MSG HEX 26 ;cr
 HEX 7C4A595B0B7842530B ;Warp Six
 HEX 6969780B ;BBS
 HEX 7B6F0B ;PD
 HEX 5D4E59584244450B ;version
 HEX 19051E05 ;2.5.
 HEX 26 ;cr
 HEX 68594E4A5F4E4F0B ;Created
 HEX 49520B ;by
 HEX 6142460B ;Jim
 HEX 6D4E595905 ;Ferr.
 HEX 2626AB ;cr cr end

* ASCII code 48(0) = 27 = 1B
* ASCII code 49(1) = 26 = 1A
* ASCII code 50(2) = 25 = 19
* ASCII code 51(3) = 24 = 18
* ASCII code 52(4) = 31 = 1F
* ASCII code 53(5) = 30 = 1E
* ASCII code 54(6) = 29 = 1D
* ASCII code 55(7) = 28 = 1C
* ASCII code 56(8) = 19 = 13
* ASCII code 57(9) = 18 = 12
