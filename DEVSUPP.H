/*
 *		devsupp.h		Date=921204
 *
 *		Device driver support routines
 *
 */

/*=====================================================================*/

#ifndef OS2_INCLUDED										// has os2.h been included?
#include <os2def.h>
#endif

/*=====================================================================*/

// devstr.c
USHORT  hextoi( CHAR FAR *string );
VOID    itohex( USHORT value, CHAR FAR *string );
ULONG   hextol( CHAR FAR *string );
VOID    ltohex( ULONG value, CHAR FAR *string );
USHORT  atoin( CHAR FAR *string );
ULONG   atoln( CHAR FAR *string );

// devsupp.c
CHAR  FAR *ScanSwitch( CHAR FAR *string, CHAR switchChar );
CHAR  FAR *GetString( CHAR FAR *inpStr, CHAR FAR *outpStr );
VOID  GetDeviceName( CHAR FAR *inpStr, CHAR FAR *devName );

// ddmemstr.asm
VOID  _dmemcpy( VOID FAR *dest, VOID FAR *src, USHORT numBytes );
VOID  _dmemset( VOID FAR *dest, USHORT value, USHORT numBytes );

/*=====================================================================*/
