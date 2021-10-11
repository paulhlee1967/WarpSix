* Macros for the GS.LOADER
* Public domain version 2.4.

_ReadBParam MAC 
 Tool $C03 
 <<< 
LONGI MAC 
 DO ]1 
 IF MX-3/-1 
 FIN 
 IF MX/3 
 MX %10 
 FIN 
 IF MX!3/3 
 FIN 
 IF MX-2/-1 
 MX %00 
 FIN 
 ELSE 
 IF MX/3 
 FIN 
 IF MX-3/-1 
 MX %11 
 FIN 
 IF MX-2/-1 
 FIN 
 IF MX!3/3 
 MX %01 
 FIN 
 FIN 
 <<< 
LONGA MAC 
 DO ]1 
 IF MX-3/-1 
 MX %00 
 FIN 
 IF MX/3 
 MX %01 
 FIN 
 IF MX!3/3 
 FIN 
 IF MX-2/-1 
 FIN 
 ELSE 
 IF MX/3 
 FIN 
 IF MX-3/-1 
 FIN 
 IF MX-2/-1 
 MX %11 
 FIN 
 IF MX!3/3 
 MX %10 
 FIN 
 FIN 
 <<< 
Tool MAC 
 LDX #]1 
 JSL $E10000 
 <<< 
