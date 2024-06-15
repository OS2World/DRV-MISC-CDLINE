/*
 *  	stddd.h		Date=920207
 *
 *		standard def's for 'C' device drivers
 */

/*=====================================================================*/

#define DAW_CHAR		0x8000					// 1=char, 0=block
#define DAW_IDC      0x4000					// 1=IDC avail
#define DAW_IBM      0x2000					// 1=non-IBM block
#define DAW_SHR      0x1000					// 1=sup shared dev
#define DAW_OPN      0x0800					// 1=open/close, rm
#define DAW_OS2LEVEL 0x0080					// level; 001 OS/2
#define DAW_IOCTL		0x0040					// 1=generic IOCtl
#define DAW_CLK      0x0008					// 1=CLOCK device
#define DAW_NUL      0x0004					// 1=NUL device
#define DAW_SCR      0x0002					// 1=STDOUT (screen)
#define DAW_KBD      0x0001					// 1=STDIN  (keybd)

//	device driver request packet command constants

#define RP_INIT			0x00			// init proc
#define RP_MEDIACHK		0x01			// media check proc
#define RP_BLDBPB 		0x02			// build BPB proc
#define RP_READ			0x04			// read proc
#define RP_PEEK			0x05			// nondestructive read proc
#define RP_INSTATUS		0x06			// input status proc
#define RP_INFLUSH		0x07			// input flush proc
#define RP_WRITE			0x08			// write proc
#define RP_WRITEV 		0x09			// write with verify proc
#define RP_OUTSTATUS		0x0a			// output status proc
#define RP_OUTFLUSH		0x0b			// output flush proc
#define RP_OPEN			0x0d			// open proc
#define RP_CLOSE			0x0e			// close proc
#define RP_MEDIAREM		0x0f			// removable media proc
#define RP_IOCTL			0x10			// generic IOCtl proc
#define RP_MEDIARES		0x11			// reset media proc
#define RP_GETLDM 		0x12			// get logical drive mapping proc
#define RP_SETLDM 		0x13			// set logical drive mapping proc
#define RP_DEINSTALL		0x14			// deinstall proc
#define RP_PORTACCESS	0x15			// port access proc
#define RP_PARTITION		0x16			// partitionable fixed disks
#define RP_GETLUM 		0x17			// get fixed disk/logical unit map
												
//	device driver return code constants

#define RC_ERROR				0x8000
#define RC_DEV_ERROR			0x4000
#define RC_BUSY				0x0200
#define RC_DONE				0x0100
#define RC_WRITE_PROT		0x0000
#define RC_UNKOWN_UNIT		0x0001
#define RC_NOT_READY			0x0002
#define RC_UNKNOWN_CMD		0x0003
#define RC_CRC_ERROR	   	0x0004
#define RC_BAD_REQ_LENGTH	0x0005
#define RC_SEEK_ERROR		0x0006
#define RC_UNKNOWN_MEDIA	0x0007
#define RC_UNKNOWN_SECTOR	0x0008
#define RC_OUT_OF_PAPER		0x0009
#define RC_WRITE_FAULT		0x000a
#define RC_READ_FAULT	   0x000b
#define RC_GENERAL_FAULT	0x000c
#define RC_CHANGE_DISK		0x000d
#define RC_UNCERTAIN_MEDIA	0x0010
#define RC_CHAR_IO_INTER	0x0011
#define RC_NO_MONITORS		0x0012
#define RC_INVALID_PARM		0x0013

#define DEV_NAME_LEN			8

/*=====================================================================*/

typedef struct _DEVICE_HDR {
	ULONG               next;
//	struct _DEVICE_HDR  *pNextDev;
	USHORT              devAttr;
	VOID NEAR           *pStratProc;
	VOID NEAR           *pIDCProc;
	CHAR                devName[8];
	CHAR                resv[8];
	} DEVICE_HDR;

typedef struct _REQ_HEADER {
	UCHAR     reqLength;
	UCHAR     blockUnit;
	UCHAR     command;
	USHORT    status;
	ULONG     resv;
	VOID FAR  *pQueue;
	} REQ_HEADER;

typedef struct _INIT_IN {
	UCHAR      logicalUnits;
	VOID FAR   *devHlp;
	UCHAR FAR  *initArgs;
	UCHAR      firstUnit;
	} INIT_IN;

typedef struct _INIT_OUT {
	UCHAR      logicalUnits;
	VOID NEAR  *endCS;
	VOID NEAR  *endDS;
	UCHAR      resv;
	} INIT_OUT;

typedef union _INIT_DATA {
	INIT_IN   inData;
	INIT_OUT  outData;
	} INIT_DATA;

typedef struct _INIT_PACKET {
	REQ_HEADER  header;
	INIT_DATA   data;
	} INIT_PACKET;

typedef struct _IO_PACKET {
	REQ_HEADER  header;
	UCHAR       media;
	ULONG       ioAddr;
	USHORT      count; 
	ULONG       start;
	USHORT      sysFileNo;
	} IO_PACKET;

typedef struct _IOCTL_PACKET {
	REQ_HEADER  header;
	UCHAR       category;
	UCHAR       function;
	VOID FAR    *paramBufr;
	VOID FAR    *dataBufr;
	USHORT      sysFileNo;
	} IOCTL_PACKET;

typedef union _REQ_PACKET {
	REQ_HEADER    header;
	INIT_PACKET   initPacket;
	IO_PACKET     ioPacket;
	IOCTL_PACKET  ioctlPacket;
	} REQ_PACKET;

/*=====================================================================*/
