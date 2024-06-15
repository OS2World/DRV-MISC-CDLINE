/*
 *		devhlp.h			Date=921208
 *
 *		OS/2 Dev Help interface for 'C' device drivers
 */

/*=====================================================================*/

#ifndef OS2_INCLUDED										// has os2.h been included?
#include <os2def.h>
#endif

/*=====================================================================*/

#define LT_SHORT_TERM	0x0000
#define LT_LONG_TERM		0x0100
#define LT_ANY_MEMORY	0x0000
#define LT_HIGH_MEMORY	0x0200
#define LT_NORMAL			0x0000
#define LT_VERIFY			0x0400

#define LW_WAIT			0x0000
#define LW_NOWAIT			0x0001

#define UV_RX				0x0000						// read/executable
#define UV_RW				0x0001						// read/write
#define UV_FREE			0x0002						// free the selector
#define UV_RX_IOPL		0x0003						// read/executable with iopl
#define UV_RW_IOPL		0x0004						// read/write with iopl
#define UV_RW_IO_TAG		0x0005						// read/write with iopl with tag

#define UV_FORE_VIDEO	0x0000						// foreground only video selector

#define BF_INTERRUPT		0x0000						// blocking is interruptible
#define BF_NOINTERRUPT	0x0001						// blocking is not interruptible

#define BL_NORMAL			0x0000						// normal wakeup from Block
#define BL_TIMEOUT		0x0100						// timeout wakeup
#define BL_ABNORMAL		0x0200						// abnormal wakeup
#define BL_INTERRUPT		0x0400						// sleep was interrupted

#define INT_NOSHARE		0x0000						// nonshared interrupt
#define INT_SHARE			0x0001						// shared interrupt

#define AP_HIGH			0x0000						// allocate above 1M
#define AP_LOW				0x0001						// allocate below 1M

/*=====================================================================*/

typedef struct _ATTACH_REC {
	VOID FAR  *realEntry;								// real mode IDC entry point
	SEL       realDS;										// real mode DS
	VOID FAR  *protEntry;								// protected mode IDC entry point
	SEL       protDS;										// protected mode DS
	} ATTACH_REC;

typedef struct _MESSAGE_REC {
	USHORT  idMsg;
	USHORT  numMsg;
	CHAR    message[1];
	} MESSAGE_REC;

typedef struct _STACK_REC {
	USHORT  length;
	USHORT  flags;
	USHORT  level;
	USHORT  stackCLI;
	USHORT  stackSTI;
	USHORT  stackEOI;
	USHORT  nest;
	} STACK_REC;

/*=====================================================================*/

VOID    DevHelpInit( VOID FAR *devHlpEntry );
USHORT  AllocGDTSel( SEL FAR *selArray, USHORT num );
USHORT  AllocPhys( ULONG size, USHORT flag, ULONG FAR *address );
USHORT  AttachDD( ATTACH_REC FAR *attachData, CHAR FAR *devName );
USHORT  Block( VOID FAR *reqPacket, ULONG interval, USHORT flag );
USHORT  DisplayMessage( MESSAGE_REC FAR * );
VOID    EOI( USHORT level );
USHORT  FreePhys( ULONG address );
USHORT  GetDOSVar( USHORT type, ULONG *var );
USHORT  InternalError( CHAR FAR *message, USHORT length );
USHORT  Lock( SEL selector, USHORT flag );
USHORT  PhysToGDTSel( ULONG address, USHORT length, SEL selector );
USHORT  PhysToUVirt( ULONG address, USHORT length, USHORT reqType, 
				USHORT tagType, VOID FAR *vAddr );
USHORT  PhysToVirt( ULONG address, USHORT length, VOID FAR *vAddr );
USHORT  PullReqPacket( VOID *queue, VOID FAR * FAR *reqPacket );
USHORT  PushReqPacket( VOID *queue, VOID FAR *reqPacket );
USHORT  ProtToReal( VOID );
USHORT  RealToProt( VOID );
USHORT  StackUsage( STACK_REC FAR *stackUsage );
USHORT  ResetTimer( VOID (FAR timerFunc)( VOID ));
USHORT  Run( VOID FAR *event );
USHORT  SemClear( HSEM handle );
USHORT  SemHandle( ULONG idSem, USHORT flag, HSEM *handle );
USHORT  SemRequest( HSEM handle, ULONG timeOut );
USHORT  SentEvent( USHORT event, USHORT arg );
USHORT  SetIRQ( VOID (FAR intrFunc)( VOID ), USHORT level, USHORT flag );
USHORT  SetTimer( VOID (FAR timerFunc)( VOID ));
VOID    TCYield( VOID );
USHORT  TickCount( VOID (FAR timerFunc)( VOID ), USHORT count );
VOID    Unlock( ULONG addr );
USHORT  UnSetIRQ( USHORT level );
USHORT  VerifyAccess( VOID FAR *ptr, USHORT num, USHORT type );
USHORT  VirtToPhys( VOID FAR *ptr, ULONG FAR *addr );
VOID    Yield( VOID );

VOID    BreakPoint( VOID );
USHORT  SelectorLimit( SEL selector );

USHORT  CopyPhysToVirt( VOID FAR *ptr, ULONG physAddr, USHORT length );
USHORT  CopyVirtToPhys( ULONG physAddr, VOID FAR *ptr, USHORT length );
USHORT  CopyPhysToPhys( ULONG destAddr, ULONG srcAddr, USHORT length );

/*=====================================================================*/