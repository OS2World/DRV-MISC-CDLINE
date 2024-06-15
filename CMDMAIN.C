/*
 *		cmdmain.c		Date=930103
 *
 *		Command line device driver.
 */

/*=====================================================================*/

#define INCL_KBD
#define INCL_DOSFILEMGR
#define INCL_DOSPROCESS
#define INCL_DOSMISC
#include <os2.h>

#include <stddd.h>
#include <devhlp.h>

#include <string.h>

#include <devsupp.h>

/*=====================================================================*/
					
#define STDIN			0								// standard in handle
#define STDOUT			1								// standard out handle

#define HKBD			0								// default handle for keyboard

/*=====================================================================*/
					
extern VOID _cdecl NEAR  CmdLineStrat( VOID );

USHORT NEAR CmdLineInit( REQ_PACKET FAR *pReqPak );

USHORT NEAR NoFunc( REQ_PACKET FAR *pReqPak );
	
/*=====================================================================*/

DEVICE_HDR  DevHdr[1] = {						// device driver header
					{ -1L,
					( DAW_CHAR | DAW_OS2LEVEL | DAW_IOCTL ),
		    		(VOID NEAR *) CmdLineStrat,
					(VOID NEAR *) 0,
					"CMDLINE$"
					}};

/*=====================================================================*/

//		jump table for control/debug device

USHORT  (NEAR *CmdLineProc[])( REQ_PACKET FAR * ) = {
				CmdLineInit,				// init proc
				NoFunc,						// media check proc
				NoFunc,						// build BPB proc
				NoFunc,						// unused
				NoFunc,						// read proc
				NoFunc,						// nondestructive read proc
				NoFunc,						// input status proc
				NoFunc,						// input flush proc
				NoFunc,						// write proc
				NoFunc,						// write with verify proc
				NoFunc,						// output status proc
				NoFunc,						// output flush proc
				NoFunc,						// unused
				NoFunc,						// open proc
				NoFunc,						// close proc
				NoFunc,						// removable media proc
				NoFunc,						// generic IOCtl proc
				NoFunc,						// reset media proc
				NoFunc,						// get logical drive mapping proc
				NoFunc,						// set logical drive mapping proc
				NoFunc,						// deinstall proc
				NoFunc,						// port access proc
				NoFunc,						// partitionable fixed disks
				NoFunc,						// get fixed disk/logical unit map
				NoFunc,						// unused
				NoFunc,						// unused
				NoFunc,						// unused
				NoFunc,						// unused
				NoFunc						// shutdown
				};

#define NUM_CMDS		0x1c

/*=====================================================================*/

CHAR  InitMsg1[] = "\r\nOS/2 Command Line Device Driver.\r\n";
CHAR  InitMsg2[] = "Version 1.00, (c) Copyright Richard Holm, 1993.\r\n";
CHAR  InitMsg3[] = "All rights reserved.\r\n";

CHAR  PromptMsg[] = "\r\nPress ESC for command prompt...\n\r";

CHAR  KbdErrMsg[] = "\r\nERROR: Cannot read keyboard.\n\r";

CHAR  LineSkip[4] = "\r\n\r\n";

/*=====================================================================*/

USHORT CmdLineMain( REQ_PACKET FAR *pReqPak ) {
	USHORT  status;

	if ( pReqPak->header.command <= NUM_CMDS )
		status = (*CmdLineProc[pReqPak->header.command])( pReqPak );
	 else
		status = NoFunc( pReqPak );

	return( status );
	}

/*=====================================================================*/

USHORT NEAR CmdLineInit( REQ_PACKET FAR *pReqPak ) {
	BOOL         done=FALSE;
	KBDKEYINFO   key;
	RESULTCODES  result;
	USHORT       i;

	DosPutMessage( STDOUT, _fstrlen( InitMsg1 ), InitMsg1 );
	DosPutMessage( STDOUT, _fstrlen( InitMsg2 ), InitMsg2 );
	DosPutMessage( STDOUT, _fstrlen( InitMsg3 ), InitMsg3 );

	DevHelpInit( pReqPak->initPak.data.inData.devHlp );

	_fstrupr( pReqPak->initPak.data.inData.initArgs );

	KbdPeek( &key, HKBD );

	DosPutMessage( STDOUT, _fstrlen( PromptMsg ), PromptMsg );

	for ( i = 0; i < 20 && !done; i++ ) {
		DosSleep( 250L );

		if ( KbdCharIn( &key, IO_NOWAIT, HKBD )) {
			DosPutMessage( STDOUT, _fstrlen( KbdErrMsg ), KbdErrMsg );
			break;
			}

		if ( key.fbStatus & FINAL_CHAR_IN ) {
			switch ( key.chChar ) {
				case '\x1b' :
     				DosExecPgm( NULL, 0, EXEC_SYNC, "CMD\0", NULL, &result, 
						"C:\\OS2\\CMD.EXE" );
					done = TRUE;
					break;

				case '\x0d' :								// CR key
				case '\x20' :								// space key
					done = TRUE;
					break;

				default :
					DosBeep( 1000, 100 );
					break;
				}
			}
		}

	pReqPak->initPak.data.outData.logicalUnits = 0;
	pReqPak->initPak.data.outData.endCS = 
			SelectorLimit( HIUSHORT((VOID FAR *)CmdLineInit ));
	pReqPak->initPak.data.outData.endDS = 
			SelectorLimit( HIUSHORT((VOID FAR *)&DevHdr ));

	return( RC_DONE );
	}

/*=====================================================================*/

USHORT NEAR NoFunc( REQ_PACKET FAR *pReqPak ) {
	
	return( RC_DONE | RC_ERROR | RC_UNKNOWN_CMD );
	}

/*=====================================================================*/
