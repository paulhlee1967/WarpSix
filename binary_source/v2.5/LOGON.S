* LOGON: save time user logged on at

LOGON JSR GETTIME
 LDA TIME+1 hour
 STA STARTHR save logon time
 LDA TIME minutes
 STA STARTMIN
:EXIT RTS  and exit.
