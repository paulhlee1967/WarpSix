0
2
0
1

PREFS.D File specifications:

ES  Line 1: Entry security level (default is 0 **)
WS  Line 2: Write (upload) security level (default is now 3)
MO  Line 3: Members only flag (0=everyone, 1=members only)
RB  Line 4: ** New ** Required baud rate to download via Xmodem in this library,
where 1=300 baud (default), 2=1200 baud, 3=2400, 4=4800, 5=9600, 6=19200.
Caution: if you set this value higher than 3, NOBODY will be able to download
files.
