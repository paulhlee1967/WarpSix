Read Me First - Warp Six BBS - Page 1

Warp Six BBS, created by Jim Ferr
Updated by Frank Kucharski, and Scott Johnson

Public domain version 3.0
March 2017.
Prior version (2.5) released on June 23, 1994.

Contents:

About Warp Six BBS
How to Update from shareware version 8.0 or later to PD 3.0
PD Version 3.0 Changes
PD Version 2.5 Changes
PD Version 2.4 Changes
PD Version 2.3 Changes
PD Version 2.2 Changes
PD Version 2.1 Changes
PD Version 2.0 Changes


ABOUT WARP SIX BBS

Warp Six BBS is a full featured bulletin board program written in "normal" AppleSoft BASIC, with modem drivers you "CALL" to do modem related things. This makes Warp Six BBS easy to modify to suit your needs. To make full use of Warp Six BBS, you should have some familiarity with AppleSoft BASIC and some experience editing AppleSoft programs and short text files on disk. Please take note that the documentation included with Warp Six BBS does not attempt to teach you how to program. However, programming is not necessary to get your bulletin board online -- it is advantageous when you are customizing your system.

While you don't need to know how to program, you should make an effort to read all of the documentation. You can skim over details like file structure information, but you should carefully read this file as well as Getting.Started and Modem.Doc. Another important file to consult is Trouble.Doc, which contains answers to many common questions.

Warp Six BBS was written during the summer of 1985, and the original Warp Six BBS went online September 12th of that year. Since that time, Warp Six BBS has been re-written and improved on countless occasions. On August 1st, 1992, Warp Six BBS was placed into the public domain by its original author (Jim Ferr). This means you don't have to pay any shareware fee and you can do with the software whatever you wish. Warp Six is still being improved now and then by Jim and by the sysops who use it, who continue to write modifications and suggest improvements.

                             A note from Jim
                             ===============
    I am grateful to the Warp Six sysops that made shareware and freeware contributions over the years. It is to those individuals that the public domain releases are dedicated. Please note I cannot accept shareware fees or donations, and my support will be limited to answering questions sent by mail or electronic mail. The software is provided "as-is" without any warranty whatsoever.

TO CONTACT THE AUTHORS:
~~~~~~~~~~~~~~~~~~~~~~~
Jim Ferr                            photoenthusiastic@gmail.com
Ontario, Canada                                           
                                                 

Frank Kucharski (deceased)      
Ontario, Canada                    
                                                 

Scott Johnson                       Scott@IowaJohnsons.Com
Des Moines, IA USA                 
                                                
                           
                                

HOW TO UPDATE FROM VERSION 8.0 OR LATER TO PD VERSION 3.0

Please read the READ.ME file included with the UPDATER program. It will explain in detail how to do the update on a working system.


  -=[ PUBLIC DOMAIN VERSION 3.0 CHANGES ]=-

Driver changes:

- Added support to connect to the BBS system over the internet
- Users with security level 8 can now see locked files
- Added ANSI auto-detect support
- Added an increased delay when modems connect to allow better detection of
  emulation codes (PSE and ANSI)
- Moved externals to the ProDOS /RAM disk

Program changes:

- Users can now logon with their NAME or their ID# (for those infrequent
   callers who manage to lose their account info, logon as a new user, and
   then page you 50 times because they're not validated and can't get their
   mail...<sigh> )

- We have added a forum queueing feature which allows users to select which
   forums they will read during a quickscan or continuous quickscan. You set
   the queue from the utility menu and after that your deselected forums will
   be skipped during scans. All forums are still active when you visit them
   manually.

- Added support for co-sysop security level (SL8). This gives the co-sysop(s)
   access to most of the sysop features but not all of them.

- Added support for a second password for co-sysops. It is a DIFFERENT one
   from the sysop remote password. When a co-sysop is upgraded to SL8, the
   system will prompt them for their new security code the next time they
   logon. There is also an option in the SYSOP.UTIL program for co-sysops
   to change their security code.

- Added a guest account for users who want to take a peek before logging on.
   Also for those "one time callers" who logon, look around, and decide not
   to call back, but neglect to let you know they don't plan to call back...

- Added a search function in the SYSOP.UTIL program to find a user by full
   name, partial last name, or alias. If searching by name it will display
   alias and ID# upon a successful find, and visa-versa.

- Added a "sysop doing user maintenance" feature which allows the sysop
   to enter the SYSOP.UTIL program while a user is online. Just activate
   the keyboard, and press Closed-Apple-Return at the main menu prompt.
   This is very nice for validating users on-the-spot when you have caller
   ID on the phone line.

- Speeded up the routines that search for user names and aliases when
   replying to mail and sending private mail from the forums.

- Added support for sending mail to a users ID# as well as their name or alias.

- Added support for replying to one of a LIST of sysops or co-sysops with
   the report to sysop command. A list is created in much the same style as
   the DATA.F files. ANY users can be added to this list, even if they have a
   security level lower than 8.

- Added a carbon copy feature when sending mail, replying to mail, or sending
   a private response from the forums. Carbon copy also supports ID#s.

- Added some memory management to all of Warp Six using the STORE and
   RESTORE commands that Jim spoke of in earlier versions.

- Split the WARP6.BBS file in half to make room for some of the features in
   this list. The new file that was "spawned" is named W6.MESSAGE. It contains
   all of the E-mail and forum routines.

- Rewrote the SORTER program so it uses a shell sort instead of a bubble sort.
   This DRAMATICALLY shortens the time a sort takes. The user list is saved
   in either a 2 column (real names) or 4 column (alias) list. The sort
   command was moved to the sysop utilities (where it really belonged to
   begin with, IMHO). The sort routine no longer has to restart the system
   after a sort. You are returned to sysop utilities.

- Purge will now ask you for the maximum security level to consider. If you
   enter "2" then all users with SL3 and higher will be skipped regardless
   of how stale the account may be. This helps reduce the amount of manual
   purges you must do. Just assign an SL higher than the purge value for
   friends and VIPs that you want permanent.

- COPY.UTIL has been modified and integrated into the sysop utilities. It
   supports copy, move, delete, lock, and unlock on BATCHES of files. Files
   can be selected from a list by number instead of typing them in manually.

- Updated the "waiting for logon" screen. It has a new look and some new
   information. The sysop no longer has to logon to see if there is mail. The
   screen shows how much mail is waiting and how much is new.

- Added a door game path to SYS.DATA. A door game launcher is now included.
   It is much simpler to add a door game to the BBS. You can disable the
   launcher if you don't want games.

- Modified flag entry in REC.DATA to be 15030, as a flag to indicate this
   system supports version 3.0 or later. UPDATER will make this change when
   you update from an earlier version.


  -=[ PUBLIC DOMAIN VERSION 2.5 CHANGES ]=-

Driver changes:

- Updated the answer routine in the GS.Driver to support connect result
   codes for 38400 and 57600 bps. Tested this with a Hayes Accura 288 V.FC +
   Fax. This may work with another modem if it reports '28' for CONNECT 38400
   and '18' for CONNECT 57600. The IIe driver still supports a maximum speed
   of 19200 bps. I have discovered that although 38400 bps does not work
   with a normal IIgs running at 2.8 MHz, it works fine when using a TransWarp
   GS at 6 MHz. In other words, to use 38400 or 57600 you will need to
   accelerate your IIgs. If you try any other type of accelerator (ZipGS?),
   let me know if it works; Applied Engineering went out of business recently.

- Scott Johnson reported a cosmetic bug in the Xmodem receive routines.
   They were not resetting the "retries" count for the sysop display between
   files. This has been fixed.

Program changes:

- Updated system to support 400 users instead of 200. Changed the "200" to
   "400" in lines 1060 and 1850 of ADD.USER and line 8040 of ADD.A.FORUM to
   support this. To use version 2.5 with an existing system, you must run the
   BBS, get into Sysop.Utils, enter P for ProDOS command and enter:

CHAIN FORUM.UPDATE,@1000

- The FORUM.UPDATE program will explain itself and run with your okay. The
   program must be located in your BBS root directory (by default,
   /HD1/WARP6/BBS), so it can read SYS.DATA to get information on your
   forums. This will add capacity for additional users to your existing
   forums. Otherwise, as soon as any user with an ID greater than 1200 hits
   a forum, its system error time. 

- Modified the Add.User program to give all new users one letter waiting.
   The system uses the COPY module to copy the "NewUserMail" file from the
   LOGS directory to the EMAIL directory with the correct filename for the
   new user. You can modify the NewUserMail file in the LOGS directory to be
   your generic welcome in E-Mail for new users. Also modified Add.User to
   force new users to enter their ID number and password when entering the
   system for the first time. These changes were suggested by Neal Layton.

- Added a quick hack of a utility called QUICK.SYSOP to the EXTRAS directory.
   You can run this program to set up fresh USERS and REC.DATA files, to start
   your user file from scratch. It must be run from the LOGS directory where
   the USERS file is located. You can change the variable assignments to
   customize your sysop record, or do it the way I describe in Trouble.Doc.

- Modified flag entry in REC.DATA to be 17777, as a flag to indicate this
   system supports version 2.5 or later. The flag is used by the FORUM.UPDATE
   program to determine if it needs to run or not. In other words, the
   FORUM.UPDATE program will put this flag in REC.DATA after it is run, and if
   you try to run it again it will inform you that you have already updated.

- By request, I have disabled sysop (security level 9 users, really)
   immunity to the normal timeout. As sysop, if you call in remotely and sit
   idle, you'll get hung up on by the system with the best of them.

- I've added an option when downloading to automatically log you off after
   a download is complete. This was also by request. Thanks, Frank!

- Another sysop (Ken Gagne, I believe) reported the COPY.UTIL's input routine
   hadn't been converted to the CALL M3$ method; this has been fixed.

- I noticed that my E-Mail welcome message in PD version 2.4 was present, but
   the sysop's user record did not indicate a letter waiting, so most users
   will have missed reading it. It was there in the EMAIL directory. This has
   been fixed in version 2.5.

  -=[ PUBLIC DOMAIN VERSION 2.4 CHANGES ]=-

Program changes: 

- Went back to the old method of getting input into the first string variable
   in memory, instead of named variables. Changed all routines at line 100 and
   130 (in all BASIC programs) to do a CALL M3 (as before) and I$=MID$(RI$,1)
   to return input to I$ instead of "CALL M3,I$". I found some problems too
   difficult to fix with the named string method, so rather than leave the
   reliability of the system in doubt, I've gone back to the old method. This
   info only has ramifications to those who have made modifications to the
   system.

- Fixed a minor bug in Add.User that refused to let a new user not interested
   in the system from "not continuing".


  -=[ PUBLIC DOMAIN VERSION 2.3 CHANGES ]=-

Driver changes: 

- fixed bug in word wrap. 
- Removed dial routines to save memory. 
- Updated GS.Driver to support 38400 bps maximum. 
- Updated Xmodem RECEIVE so it ALWAYS locks received files. (Previously,
   it would not lock files uploaded by anyone with security level 9.)

BASIC program changes: 

- fixed calls today bug in LOGON program.
- updated version number in wait for call screen. 
- In WARP6.BBS, fixed sysop mailbox limit when user sends E-Mail by name
   instead of R)eport to sysop. 
- Fixed serious GOSUB bug that orphaned the "Leaving last forum/returning
   to main" message. 
- In SYSOP.UTIL, fixed a minor problem. 
- In XFER.UTIL, fixed minor problem I had already issued a fix for after the
   release of version 2.2.


  -=[ PUBLIC DOMAIN VERSION 2.2 CHANGES ]=-

Driver changes:

- Found a bug in new named string feature; when remote user times out, failed
   to move TXTPTR to the next statement, resulting in an Error 16 at line 100
   and the dreaded, "A system error has occurred..." Fixed this bug.

- Removed "Answering..." from answer routine. It now simply says "Ring." and
   then answers the phone. This was done to save memory in the largest driver,
   the GS.Driver, which just fits into the same space we've been using since
   version 8.9.

Program changes:

- Renumbered some lines in LOGON (3000-3999 back to 2000-2999) and modified
   the reference to LOGON in the ADD.USER program so it chains to line 2000
   again.

- Added code to LOGON to POKE an initial timeout of 1 minute at the ID number
   prompt (line 1410), and back to 4 minutes after the user has entered
   his/her password. On leaving LOGON, the timeout is set to 2 minutes to catch
   people with auto-logon macros who walked away from their computers. This
   means that the first time they get to the Main command prompt, the timeout
   is still 2 minutes. The timeout is reset to the system default of 4 minutes
   in Warp6.BBS at line 8010. (To change the timeout, do a "POKE BA + 62,1",
   where the 1 is the number of minutes. 30 seconds from expiry time, a "Hello"
   warning is printed. If no response is received, the system hangs up and
   resets.)


  -=[ PUBLIC DOMAIN VERSION 2.1 CHANGES ]=-

Driver changes:

- Fixed a bug in XModem receive that caused the ProDOS extension to fail
   every time. The old code was checking the CRC low byte first, but the new
   CRC routines store the high byte in that location, so the CRC would never
   match.

- Updated the drivers to support input to named strings, so instead of doing
   a CALL M3 to get input, you can do CALL M3,I$. 


  -=[ PUBLIC DOMAIN VERSION 2.0 CHANGES ]=-

Driver changes:

- Updated all drivers for use with high speed modems with support to 19200
   bps with hardware handshaking. Tested with Hayes ULTRA 96 only. Other
   modems will also work but you'll have to figure out the correct commands
   for your Modem.Init file. (More on this in Modem Doc.)

- Completely re-wrote the IIGS interrupt handler for speed. It can handle
   Xmodem 4K uploads from a caller connected with a 9600 bps modem using
   LAPM data compression (CARRIER 9600, CONNECT 19200) without losing data.

- The Super Serial Card driver will not do hardware handshaking due to a bug
   in the ACIA 6551 chip, so you'll have to configure your modem to disable
   error control and handshaking if you are using the Super Serial Card. Due
   to Super Serial Card limitations, I recommend you don't attempt to run the
   system at speeds greater than 9600 bps.

- Eliminated the GS.HSKi driver and support for oddball GS modem cables. Your
   cable must now conform to the specs for the remaining GS.Driver, using GPi
   for carrier detect. (See Modem.Doc for pinouts.)

- Added functionality to the upper case convert flag to do lower case
   conversion. To get a line of input in lower case, do a POKE UC,1 before doing
   your GOSUB 100 or 130. Make sure you do a POKE UC,0 or POKE UC,255 to set it
   to full case or upper case after you are done.

- Added functionality to the hidden mode, used for password entry. Currently
   it echoes * characters as the user types his or her password. To shut off
   echo altogether, use POKE MD,1 instead of POKE MD,255. Hidden mode
   (without echo or with asterisk echo) is automatically shut off after use
   -- you don't have to explicitly do a POKE MD,0 to shut it off before getting
   a line of normal input.

   ** The two additions above were added for those interested in making Warp
   Six appear more like a Unix system... an exercise left to the student at
   this point. :)

- Re-wrote the GS.Driver to save a lot of space in memory and tackle the
   Zilog 8530 more efficiently. Thanks to Greg Schaefer, author of ProTERM,
   for assistance in this. Here's a plug for ProTERM, from InTrec Software,
   at (602) 992-1345: it's the best Apple II terminal program in existence.
   And it will soon be a Macintosh program.

- Fixed video driver support to permit full 80 column lines without cursor
   or scrolling problems. The default video width is now set at 79 characters,
   but the built-in TYPE command can display 80 character files. This was done
   in preparation for Internet access, which I am working on now and then. (No
   promises!)

- Updated error messages in the WARP6.LOADER programs to be nicer when
   exiting. For instance, if you launch the GS drivers on a IIe, you'll get a
   polite error message and the program will ask you to "Hit Return to exit".
   When you hit return, it will return to the calling program, i.e. your program
   selector or whatever.

- Updated check for AppleTalk active on the IIGS so it now will detect the
   Apple II EtherTalk card, which was never released. Due to heavy interrupt
   activity, Warp Six BBS is not compatible with AppleTalk and will not run
   when it is active; a polite error message is displayed and then you are
   returned to the launching application or ProDOS program selector.

- The Hayes hangup flag is no longer used. The driver first tries hanging up
   with DTR, then does the Hayes hangup. Your users will only see the familiar
   +++ sequence if your cable/modem does not support DTR hangup.

Program changes:

- Modified the LOGON program to support high speed modems with the addition
   of the following three lines:

   50 POKE BA + 47,3: REM 1=300 bps 2=1200 3=2400 4=4800 5=9600 6=19200
   55 POKE BA + 449,255: REM 255=Match bps to incoming calls, 0=Fixed bps
   60 POKE BA + 450,0: REM RTS/CTS handshaking off. 255=on

   To enable the drivers for high speed modems, you must POKE in a higher
   default baud rate in line 50 of LOGON. You also have to do a POKE to enable
   hardware handshaking (line 55) and if you wish, to force the driver to talk
   to the modem at a fixed baud rate (line 60). It is preferable not to use a
   fixed baud rate to talk to the modem if possible; on the Hayes you add the
   S36=5 command to the Modem.Init file to accomplish this. As well, in
   Modem.Init you must enable hardware handshaking on the modem if you wish
   to use it. (On the Hayes the &K3 command does this.)

   Here is the recommended Modem.Init for the Hayes ULTRA 96. Similar modems
   will have similar requirements:

   AT&F&K3E0V0S0=0S7=45
   ATX4S36=5H0
   AT&C1&D2

- Added a copy utility to the system. To enter it, get into System Utils and
   type P for ProDOS command, then CHAIN COPY.UTIL@1000. There is no syntax
   checking as you enter filenames, but error checking will report any
   problems if you make a typo. The copy utility can copy any file that ProDOS
   8 can manipulate except a directory.

- Fixed problem in line 100 of most BASIC programs that could cause
   Open-Apple-L to logoff to loop forever.

- Updated documentation files to be readable with AppleWorks 2.x instead
   of requiring AppleWorks 3.0.

