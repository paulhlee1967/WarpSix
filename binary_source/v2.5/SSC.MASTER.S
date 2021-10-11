 LST OFF

BEGIN = $8D00 ;we need up to $99FF

 XC ON

* Warp Six BBS SSC Master file
* Public domain version 2.5

* Instructions: 1) assemble this file as is.
*
* 2) change SSC to LOCAL and change NOIRQ=0 to =1
*    and assemble again.
*
* You can change the pathname used to SAVe the object
* code to whatever you desire.

GS = 0 ;always 0
NOIRQ = 0 ;set for LOCAL.DRIVER
W6 = 1 ;always 1 for Warp Six

 PUT EQU ;equates
 PUT MAIN ;main module
 LST OFF

 PUT GETLN ;line input routine
 PUT FILTER ;input filter
 PUT OUTPUT ;output routine
 PUT TOBASIC ;pass data to BASIC
 PUT WRAP ;word wrap routines
 PUT CURSOR ;cursor routines
 PUT SHIFT ;case shift routines
 PUT PARSE ;parse BI cmd
 PUT TYPE ;TYPE command
 PUT WARNINGS ;warning msgs
 PUT LOGON ;logon routine
 PUT RIGHTS ;copyright routine

 PUT SSC.RTNS ;machine specific rtns

 PUT END ;make sure we didn't run
   ;out of memory

 SAV /HD1/WARP6.INFO/DRIVERS/SSC.DRIVER
