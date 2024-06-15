;
;	devhlp.inc	Date=921207
;
;	DevHelp interface for ASM device drivers
;
;

;========================================================================

YIELD		EQU	002h			; yields the CPU to any eligible threads
BLOCK		EQU	004h			; blocks requesting thread
RUN		EQU	005h			; unblocks blocked thread
SEM_REQUEST	EQU	006h			; request a semaphore
SEM_CLEAR	EQU	007h			; clears (releases) a RAM or system semaphore
SEM_HANDLE	EQU	008h			; creates or releases a semaphore handle
PHYS_TO_VIRT	EQU	015h			; converts a physical address to virtual address
VIRT_TO_PHYS	EQU	016h			; converts virtual address to a physical address
PHYS_TO_UVIRT	EQU	017h			; converts a physical address to a virtual address
ALLOC_PHYS	EQU	018h			; allocates a fixed block of memory
FREE_PHYS	EQU	019h			; releases memory allocated by _AllocPhys
SET_IRQ		EQU	01Bh			; captures hardware interrupt vector
UNSET_IRQ	EQU	01Ch			; releases ownership of a hardware interrupt
VERIFY_ACCESS	EQU	027h			; verifies access to a range of memory addresses
ATTACH_DD	EQU	02Ah			; attach to a device
ALLOC_GDT_SEL	EQU	02Dh			; allocate a GDT selector
PHYS_TO_GDT_SEL	EQU	02Eh			; maps a 32 bit physical address to a GDT selector
REAL_TO_PROT	EQU	02Fh			; switch form real mode to protected mode
PROT_TO_REAL	EQU	030h			; switch from protected mode to real mode
EOI		EQU	031h			; issues end of interrupt
UNPHYS_TO_VIRT	EQU	032h			; releases virtual addresses
STACK_USAGE	EQU	03ah			; indicate stack usage
DISPLAY_MESSAGE	EQU	03dh			; display a message

PVT_DSSI	EQU	000h			; put result of PhysToVirt in ds:si
PVT_ESDI	EQU	001h			; put result of PhysToVirt in es:di

BL_NORMAL	EQU	0000h			; normal wakeup from Block
BL_TIMEOUT	EQU	0100h			; timeout wakeup
BL_ABNORMAL	EQU	0200h			; abnormal wakeup
BL_INTERRUPT	EQU	0400h			; sleep was interrupted

;========================================================================

ATTACH_REC	STRUC
ar_realEntry	dd	?			; real mode entry point for DD
ar_realDS	dw	?			; real mode DS
ar_protEntry	dd	?			; protected mode entry point for DD
ar_protDS	dw	?			; protected mode DS
ATTACH_REC	ENDS

;========================================================================

;	PDDPhysToVirt

;	Notes:	This macro converts a physical address to a virtual address

;	Modified registers:	ax, bx, cx, dx

@PDDPhysToVirt	MACRO	pvAddr,pvLen,pvType
		mov	ax,WPTR pvAddr+2	; MSW of i/o buffer address
		mov	bx,WPTR pvAddr		; LSW of i/o buffer address
		mov	cx,WPTR pvLen		; length of i/o buffer
		mov	dh,pvType		; specifies destination of result
		mov	dl,PHYS_TO_VIRT		; convert physical to virtual
		call	DevHelp			; call kernel
		ENDM

;========================================================================

;	PDDPhysToVirt

;	Notes:	This macro releases virtual memory

;	Modified registers:	dx

@PDDReleaseVirt	MACRO
		mov	dl,UNPHYS_TO_VIRT	; release virtual memory
		call	DevHelp			; call kernel
		ENDM

;========================================================================
	