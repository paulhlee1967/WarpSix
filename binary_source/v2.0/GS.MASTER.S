 LST OFF

BEGIN = $8D00 ;we need up to $99FF

 XC ON

* Warp Six BBS GS driver master file
* Public domain version 2.0

* Instructions: assemble this file as is.
*
* You can change the pathname used to SAVe the object
* code to whatever you desire.

NOIRQ = 0 ;always
GS = 1 ;always
W6 = 1

 PUT EQU ;equates
 PUT MAIN ;vectors
 PUT STANDARD ;standard routines
 PUT GS.RTNS

 PUT END ;make sure we didn't run
   ;out of memory

 SAV /HD1/WARP6.INFO/DRIVERS/GS.DRIVER
