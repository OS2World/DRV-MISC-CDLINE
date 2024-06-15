/*
 *		devstr.h			Date=920330
 *
 *		device driver string functions
 *
 */

/*=====================================================================*/

USHORT  hextoi( CHAR FAR * );
VOID    itohex( USHORT, CHAR FAR * );
ULONG   hextol( CHAR FAR * );
VOID    ltohex( ULONG, CHAR FAR * );

USHORT  atoin( CHAR FAR * );
ULONG   atoln( CHAR FAR * );

/*=====================================================================*/
