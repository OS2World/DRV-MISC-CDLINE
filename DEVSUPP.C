/*
 *		devsupp.c		Date=920618
 *
 *		Funnel device driver support routines
 *
 */

/*=====================================================================*/

#include <devsupp.h>

#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include <stddd.h>

/*=====================================================================*/

CHAR FAR *ScanSwitch( string, switchChar )
CHAR  FAR *string, switchChar; {
	
	while ( *string ) {
		if ( *string == '/' && ( *(string+1) == (CHAR)tolower( switchChar ) || 
				*(string+1) == (CHAR)toupper( switchChar ))) {
			if ( *(string+2) == ':' )
				return( string+3 );
			 else
				return( string+2 );
			}

		string++;
		}

	return( NULL );
	}

/*=====================================================================*/

CHAR FAR *GetString( buffer, string )
CHAR  FAR *buffer, FAR *string; {
	
	while ( *buffer && *buffer != ' ' && *buffer != ',' && *buffer != '/' )
		*string++ = *buffer++;

	*string = '\0';

	if ( *buffer == ',' )
		return( buffer+1 );
	 else
		return( buffer );
	}

/*=====================================================================*/

VOID GetDeviceName( string, devName )
CHAR  FAR *string, FAR *devName; {
	
	_fmemset( devName, ' ', DEV_NAME_LEN );
	_fstrupr( string );
	_fstrncpy( devName, string, min( _fstrlen( string ), DEV_NAME_LEN ));
	}

/*=====================================================================*/
