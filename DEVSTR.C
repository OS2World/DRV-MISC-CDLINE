/*
 *		devstr.c			Date=921204
 *
 *		device driver string functions
 *
 */

/*=====================================================================*/

#include <devsupp.h>

/*=====================================================================*/

BOOL  isanum( CHAR );

/*=====================================================================*/

USHORT hextoi( string )
CHAR  FAR *string; {
	USHORT  num;

	num = 0;
	while ( *string ) {
		num *= 16;

		if ( *string >= '0' && *string <= '9' )
			num += ( *string-'0' );
		 else if ( *string >= 'a' && *string <= 'f' )
			num += ( *string-'a'+10 );
		 else if ( *string >= 'A' && *string <= 'F' )
			num += ( *string-'A'+10 );
		 else
		 	break;

		string++;
		}

	return( num );
	}

/*=====================================================================*/

VOID itohex( num, buffer )
USHORT  num;
CHAR    FAR *buffer; {
	CHAR    FAR *out;
	USHORT  shift, temp, mask=0xf000;

	out = buffer;
	shift = 12;
	while ( mask ) {
		temp = num & mask;
		temp >>= shift;

		temp += '0';
		if ( temp > '9' )
			temp += ( 'A'-'9'-1 );

		*out = (CHAR)temp;
		out++;
		shift -= 4;
		mask >>= 4;
		}

	buffer[4] = '\0';
	}

/*=====================================================================*/

ULONG hextol( string )
CHAR  FAR *string; {
	static ULONG  num;

	num = 0;
	while ( *string ) {
		num *= 16;

		if ( *string >= '0' && *string <= '9' )
			num += ( *string-'0' );
		 else if ( *string >= 'a' && *string <= 'f' )
			num += ( *string-'a'+10 );
		 else if ( *string >= 'A' && *string <= 'F' )
			num += ( *string-'A'+10 );
		 else
		 	break;

		string++;
		}

	return( num );
	}

/*=====================================================================*/

VOID ltohex( num, buffer )
ULONG  num;
CHAR   FAR *buffer; {
	CHAR          FAR *out;
	static ULONG  temp, mask=0xf0000000L;
	USHORT        shift;

	out = buffer;
	shift = 28;
	while ( mask ) {
		temp = num & mask;
		temp >>= shift;

		temp += '0';
		if ( temp > '9' )
			temp += ( 'A'-'9'-1 );

		*out = (CHAR)temp;
		out++;
		shift -= 4;
		mask >>= 4;
		}

	buffer[8] = '\0';
	}

/*=====================================================================*/

USHORT atoin( string )
CHAR  FAR *string; {
	USHORT  value=0, count=0;

	while ( isanum( *(string+count)))
		value = ( value*10 )+ *(string+count++)-'0';

	return( value );
	}

/*=====================================================================*/

ULONG atoln( string )
CHAR  FAR *string; {
	ULONG   value=0;
	USHORT  count=0;

	while ( isanum( *(string+count)))
		value = ( value*10 )+ *(string+count++)-'0';

	return( value );
	}

/*=====================================================================*/

BOOL isanum( ch )
CHAR  ch; {
	
	if ( ch < '0' || ch > '9' )
		return( FALSE );
	 else
	 	return( TRUE );
	}

/*=====================================================================*/