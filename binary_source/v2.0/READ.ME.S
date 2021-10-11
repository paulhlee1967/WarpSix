* Source code Read Me
* Written by Jim Ferr
* April 1993
*
* Public Domain version 2.0
*
* Here are some tidbits of information about the source code to Warp Six
* BBS to help those who will follow me.
*
* Jim Ferr, Whitby, Ontario.
*
*
*
* The source code for the modem drivers in Warp Six BBS were written with
* the Merlin assembler. To use the source files to create the modem drivers
* and Xmodem module, you only have to assemble a few of the files, some of
* them more than once after making a small change. Each file contains some
* instructions on this. To assemble the GS.LOADER, you will need Merlin 16
* or Merlin 16+. (Merlin 16+ is many times faster than older versions of
* Merlin.)
*
* The following table shows which source files you must assemble to get the
* object files (actual drivers) the system uses:
*
* Source file       Object file     Description
*
* SSC.LOADER.S ---> LOCAL.LOADER    loads modem disabled driver
*          -------> SSC.LOADER      loads SSC driver
*
* GS.LOADER.S ----> GS.LOADER       loads GS driver
*
* SSC.MASTER.S ---> LOCAL.DRIVER    modem disabled driver
*          -------> SSC.DRIVER      Super Serial card driver
*
* GS.MASTER.S ----> GS.DRIVER       GS driver
*
* XYLOADER.S -----> XYLOADER        Loads/removes XYMODEM module
* XYGLOBALS.S ----> XYMODEM         XYModem send/receive module
*
* CLOADER.S ------> CLOADER         Loads/removes COPY module
* COPY.S ---------> COPY            ProDOS COPY command (COPY FILE1,FILE2)
*
*
* The Loader programs share the ERRORS.S file, which holds loader error
* messages. The GS.LOADER uses macros in GSLOAD.MACS.S. The modem drivers
* all share the following files:
*
* Source file      Comment
*
* EQU.S            Contains system equates
* MAIN.S           Main vectors and short routines
* STANDARD.S       Standard routines
*
* In addition, each driver uses a hardware specific source file. The
* SSC.DRIVER uses the SSC.RTNS.S file, The GS.DRIVER file uses the GS.RTNS.S
* file, and the LOCAL.DRIVER uses the LOCAL.RTNS.S file.
*
* Finally, to create the XYmodem module, you need to assemble XYLOADER.S and
* XYGLOBALS.S. The XYmodem module uses the CAT.S, SEND.S, RECEIVE.S and CRC.S
* files.
*
* Two additional small files, END.S and END2.S, are used by the drivers and
* XYmodem modules to ensure your assembled object code has not gone beyond
* the available memory. If this occurs, you'll get an error during
* assembly.
*
* Memory Usage
*
* The Loader program (whether it is SSC.LOADER, LOCAL.LOADER or
* GS.LOADER) is responsible for reserving memory from BASIC.System for the
* modem driver, loading the modem driver into memory, and some other
* important tasks.
*
* VERY IMPORTANT: For actual use with Warp Six BBS, your loader must be
* renamed "WARP6.LOADER" and your driver must be renamed "WARP6.DRIVER".
*
* The following table shows the memory used by the system:
*
* $9AFF and above is BASIC.System and ProDOS
*
* $8D00 to $99FF is the memory space the modem driver occupies
* $8C00 to $8CFF is MBUF, the modem input buffer
* $8B00 to $8BFF is LINBUF, the line input buffer
* $8A00 to $8AFF is WWBUF, the word wrap buffer
* $8600 to $89FF is IOBUF, the driver's ProDOS file I/O buffer
*
* When the XYmodem module is not loaded, that's it for Warp Six memory use.
* The BASIC programs, as usual, start a $800 and work up from there, and
* BASIC variables work down from below our IOBUF.
*
* When the XYmodem module is loaded, it takes the space between:
*
* $5700-$85FF
*
* Also, the XYLOADER program resides at the bottom of page 3 ($300), and
* page 3 must be left alone while the XYMODEM module is in memory. XYLOADER
* contains routines to reserve RAM from BASIC.System, load the XYMODEM
* module, and later, to give back the RAM it reserved -- when your user
* leaves the transfer section. This modularity is nice as it leaves more
* room for the larger BASIC programs that are part of the system.
*
* The COPY command uses the same mechanism as XYLOADER and XMODEM.
*
* (As a side note, to see how much memory is available in the transfer
* section the sysop can enter / and the system will show how many bytes
* are free. Similarly, when in any forum, M will display available memory.)
