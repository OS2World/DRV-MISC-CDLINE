		PAGE    85,132
        	TITLE   DEVHELP -- DevHelp interface for 'C' device drivers
        	.386P
;
;	devhlp.asm	Date=921209
;
;	DevHelp interface for 'C' device drivers
;
;

;========================================================================

BPTR		EQU     BYTE PTR                                         
WPTR		EQU     WORD PTR
DPTR		EQU     DWORD PTR

;=========================================================================

		INCLUDE	devhlp.inc

;=========================================================================

YIELD		EQU	002h			; yields the CPU to any eligible threads
BLOCK		EQU	004h			; blocks requesting thread
RUN		EQU	005h			; unblocks blocked thread
SEM_REQUEST	EQU	006h			; request a semaphore
SEM_CLEAR	EQU	007h			; clears (releases) a RAM or system semaphore
SEM_HANDLE	EQU	008h			; creates or releases a semaphore handle
PUSH_REQ_PAK	EQU	009h			; push a request packet on the queue
PULL_REQ_PAK	EQU	00ah			; pull a request packet off the queue
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

;========================================================================

BL_NORMAL	EQU	0000h			; normal wakeup from Block
BL_TIMEOUT	EQU	0100h			; timeout wakeup
BL_ABNORMAL	EQU	0200h			; abnormal wakeup
BL_INTERRUPT	EQU	0400h			; sleep was interrupted

;========================================================================

		PUBLIC  _DevHelpInit
		PUBLIC  _AllocGDTSel
		PUBLIC  _AllocPhys
		PUBLIC  _AttachDD
		PUBLIC  _Block
		PUBLIC  _DisplayMessage
		PUBLIC  _EOI
		PUBLIC  _FreePhys
		PUBLIC  _PhysToGDTSel
		PUBLIC  _PhysToUVirt
		PUBLIC  _PhysToVirt
		PUBLIC  _ProtToReal
		PUBLIC  _PullReqPacket
		PUBLIC  _PushReqPacket
		PUBLIC  _RealToProt
		PUBLIC  _StackUsage
		PUBLIC  _Run
		PUBLIC  _SetIRQ
		PUBLIC  _UnSetIRQ
		PUBLIC  _VirtToPhys

		PUBLIC  _BreakPoint
		PUBLIC  _SelectorLimit

		PUBLIC  DevHelp

;************************************************************************

_DATA		SEGMENT WORD USE16 PUBLIC 'DATA'

Init		dw	0			; are we initialized
DevHelp		dd	?			; DevHelp entry point

_DATA		ENDS

;************************************************************************

CONST		SEGMENT WORD USE16 PUBLIC 'CONST'
CONST		ENDS

;************************************************************************

_BSS		SEGMENT WORD USE16 PUBLIC 'BSS'
_BSS		ENDS

DGROUP		GROUP	CONST, _BSS, _DATA

;************************************************************************

_TEXT		SEGMENT WORD USE16 PUBLIC 'CODE'
		ASSUME  cs:_TEXT, ds:DGROUP, es:NOTHING, ss:NOTHING

;========================================================================

init_frame	STRUC
		dw	?			; bp
		dw	?			; return address
devHelpEntry	dd	?			; DevHelp entry point
init_frame	ENDS

;------------------------------------------------------------------------

_DevHelpInit	PROC	NEAR

		push	bp			; save bp
		mov	bp,sp			; get base of stack

		push	ds			; save registers
		push	si

		mov	ax,DGROUP		; data segment
		mov	ds,ax

		mov	ax,WPTR devHelpEntry[bp]; get entry point
		mov	WPTR DevHelp,ax
		mov	ax,WPTR devHelpEntry+2[bp]
		mov	WPTR DevHelp+2,ax

		mov	Init,1			; init flag

		pop	si			; restore registers
		pop	ds
		pop	bp
		ret

_DevHelpInit	ENDP

;========================================================================					

allocGDT_frame	STRUC
		dw	?			; bp
		dw	?			; return address
arraySel	dd	?			; selector array
numSel		dw	?			; number of selectors
allocGDT_frame	ENDS

;------------------------------------------------------------------------

_AllocGDTSel	PROC	NEAR

		push	bp			; save bp
		mov	bp,sp			; get base of stack

		push	ds			; save registers
		push	di

		mov	ax,DGROUP		; data segment
		mov	ds,ax

		les	di,arraySel[bp]		; selector array

		mov	cx,numSel[bp]		; number of selectors to allocate

		mov	dl,ALLOC_GDT_SEL	; allocate a GDT selector

		call	DevHelp			; call kernel
		jc	as_exit			; was the call successful?

		xor	ax,ax			; successful

as_exit:
		pop	di			; restore registers
		pop	ds
		pop	bp
		ret

_AllocGDTSel	ENDP

;========================================================================					

allocPhys_frame	STRUC
		dw	?			; bp
		dw	?			; return address
memSize		dd	?			; memory size
memType		dw	?			; number of selectors
memAddr		dd	?			; memory address
allocPhys_frame	ENDS

;------------------------------------------------------------------------

_AllocPhys	PROC	NEAR

		push	bp			; save bp
		mov	bp,sp			; get base of stack

		push	ds			; save registers
		push	di

		mov	ax,DGROUP		; data segment
		mov	ds,ax

		mov	bx,WPTR memSize[bp]	; memory size
		mov	ax,WPTR memSize+2[bp]

		mov	dx,memType[bp]		; high or low
		shl	dx,8

		mov	dl,ALLOC_PHYS		; allocate physical memory

		call	DevHelp			; call kernel
		jc	ap_exit

		les	di,memAddr[bp]		; pointer to phys address
		mov	WPTR es:[di],bx		; LSW
		mov	WPTR es:[di+2],ax	; MSW
		xor	ax,ax

ap_exit:
		pop	di			; restore registers
		pop	ds
		pop	bp
		ret

_AllocPhys	ENDP

;========================================================================					

attachDD_frame	STRUC
		dw	?			; bp
		dw	?			; return address
attachData	dd	?			; address of attach struct
attachName	dd	?			; address of attach device name
attachDD_frame	ENDS

;------------------------------------------------------------------------

_AttachDD	PROC	NEAR

		push	bp			; save bp
		mov	bp,sp			; get base of stack

		push	ds			; save registers
		push	di

		mov	ax,DGROUP		; data segment
		mov	ds,ax

		lds	bx,attachName[bp]	; device to attach to
		lds	di,attachData[bp]	; attach data structure

		mov	dl,ATTACH_DD		; attach to a device

		call	DevHelp			; call kernel
		jc	ad_exit			; was the call successful?

		xor	ax,ax			; successful

ad_exit:
		pop	di			; restore registers
		pop	ds
		pop	bp
		ret

_AttachDD	ENDP

;========================================================================					

attachDD_frame	STRUC
		dw	?			; bp
		dw	?			; return address
blockEvent	dd	?			; event id
blockInterval	dd	?			; interval timeout
blockFlag	dw	?			; interruptible flag
attachDD_frame	ENDS

;------------------------------------------------------------------------

_Block		PROC	NEAR

		push	bp			; save bp
		mov	bp,sp			; get base of stack

		push	ds			; save registers
		push	di

		mov	ax,DGROUP		; data segment
		mov	ds,ax

		mov	bx,WPTR blockEvent[bp]	; event id
		mov	ax,WPTR blockEvent+2[bp]
						; timeout
		mov	di,WPTR blockInterval[bp]
		mov	cx,WPTR blockInterval+2[bp]

		mov	dx,blockFlag[bp]	; interruptible?
		shl	dx,8

		mov	dl,BLOCK		; block current thread

		call	DevHelp			; call kernel
		mov	ax,0
		jnc	bl_exit

		or	ax,BL_ABNORMAL		; abnormal wakeup

bl_timeout:
		jnz	bl_interrupt

		or	ax,BL_TIMEOUT		; block timed out
		jmp	bl_exit

bl_interrupt:
		or	ax,BL_INTERRUPT		; block was interrupted

bl_exit:
		pop	di			; restore registers
		pop	ds
		pop	bp
		ret

_Block		ENDP

;========================================================================					

msg_frame	STRUC
		dw	?			; bp
		dw	?			; return address
messageData	dd	?			; message data
msg_frame	ENDS

;------------------------------------------------------------------------

_DisplayMessage	PROC	NEAR

		push	bp			; save bp
		mov	bp,sp			; get base of stack

		push	ds			; save registers
		push	di

		mov	ax,DGROUP		; data segment
		mov	ds,ax

		les	di,messageData[bp]	; message data

		xor	bx,bx

		mov	dl,DISPLAY_MESSAGE	; display a message

		call	DevHelp			; call kernel

		pop	di			; restore registers
		pop	ds
		pop	bp
		ret

_DisplayMessage	ENDP

;========================================================================					

eoi_frame	STRUC
		dw	?			; bp
		dw	?			; return address
eoiLevel	dw	?			; IRQ level
eoi_frame	ENDS

;------------------------------------------------------------------------

_EOI		PROC	NEAR

		push	bp			; save bp
		mov	bp,sp			; get base of stack

		push	ds			; save registers

		mov	ax,DGROUP		; data segment
		mov	ds,ax

		mov	ax,eoiLevel[bp]		; IRQ level

		mov	dl,EOI			; signal end of interrupt

		call	DevHelp			; call kernel

		pop	ds			; restore registers
		pop	bp
		ret

_EOI		ENDP

;========================================================================					

freePhys_frame	STRUC
		dw	?			; bp
		dw	?			; return address
freeAddr	dd	?			; address of memory to free
freePhys_frame	ENDS

;------------------------------------------------------------------------

_FreePhys	PROC	NEAR

		push	bp			; save bp
		mov	bp,sp			; get base of stack

		push	ds			; save registers

		mov	ax,DGROUP		; data segment
		mov	ds,ax

		mov	bx,WPTR freeAddr[bp]	; address of memory to free
		mov	ax,WPTR freeAddr+2[bp]

		mov	dl,FREE_PHYS		; free memory

		call	DevHelp			; call kernel
		jc	fp_exit			; was the call successful?

		xor	ax,ax			; successful

fp_exit:
		pop	ds			; restore registers
		pop	bp
		ret

_FreePhys	ENDP

;========================================================================					

mapGDT_frame	STRUC
		dw	?			; bp
		dw	?			; return address
mapAddr		dd	?			; memory to map
mapLength	dw	?			; length of the segment
mapSel		dw	?			; selector to map
mapGDT_frame	ENDS

;------------------------------------------------------------------------

_PhysToGDTSel	PROC	NEAR

		push	bp			; save bp
		mov	bp,sp			; get base of stack

		push	ds			; save registers
		push	si

		mov	ax,DGROUP		; data segment
		mov	ds,ax

		mov	bx,WPTR mapAddr[bp]	; address of memory to map
		mov	ax,WPTR mapAddr+2[bp]

		mov	cx,mapLength[bp]
		mov	si,mapSel[bp]

		mov	dl,PHYS_TO_GDT_SEL	; map memory to GDT selector

		call	DevHelp			; call kernel
		jc	ps_exit			; was the call successful?

		xor	ax,ax			; successful

ps_exit:
		pop	si			; restore registers
		pop	ds
		pop	bp
		ret

_PhysToGDTSel	ENDP

;========================================================================					

uVirt_frame	STRUC
		dw	?			; bp
		dw	?			; return address
uVirtAddr	dd	?			; memory to map
uVirtLength	dw	?			; length of the segment
uVirtType	dw	?			; type
uVirtTag	dw	?			; tag
uVirtPtr	dd	?			; pointer to memory
uVirt_frame	ENDS

;------------------------------------------------------------------------

_PhysToUVirt	PROC	NEAR

		push	bp			; save bp
		mov	bp,sp			; get base of stack

		push	ds			; save registers
		push	si

		mov	ax,DGROUP		; data segment
		mov	ds,ax

		mov	bx,WPTR uVirtAddr[bp]	; address of memory to map
		mov	ax,WPTR uVirtAddr+2[bp]

		mov	cx,uVirtLength[bp]	; length
		mov	si,uVirtTag[bp]		; tag
		mov	dh,BPTR uVirtType[bp]	; type

		mov	dl,PHYS_TO_UVIRT	; map memory to LDT selector

		call	DevHelp			; call kernel
		jc	uv_err

		lds	si,uVirtPtr[bp]		; pointer to a long
		mov	WPTR ds:[si],bx		; offset
		mov	bx,es
		mov	WPTR ds:[si+2],bx	; selector

		xor	ax,ax			; no error
		jmp	uv_exit

uv_err:
		mov	ax,1			; invalid memory

uv_exit:
		pop	si			; restore registers
		pop	ds
		pop	bp
		ret

_PhysToUVirt	ENDP

;========================================================================

virt_frame	STRUC
		dw	?			; bp
		dw	?			; return address
virtAddr	dd	?			; memory to map
virtLength	dw	?			; length of the segment
virtPtr		dd	?			; pointer to memory
virt_frame	ENDS

;------------------------------------------------------------------------

_PhysToVirt	PROC	NEAR

		push	bp			; save bp
		mov	bp,sp			; get base of stack

		push	ds			; save registers
		push	si
		push	di

		mov	ax,DGROUP		; data segment
		mov	ds,ax

		mov	bx,WPTR virtAddr[bp]	; address of memory to map
		mov	ax,WPTR virtAddr+2[bp]

		mov	cx,virtLength[bp]	; length
		mov	dh,PVT_ESDI

		mov	dl,PHYS_TO_VIRT		; map memory to temporary GDT selector

		call	DevHelp			; call kernel
		jc	v_err

		lds	si,virtPtr[bp]		; pointer to a pointer
		mov	WPTR ds:[si],di		; offset
		mov	ax,es
		mov	WPTR ds:[si+2],ax	; selector

		xor	ax,ax			; no error
		jmp	v_exit

v_err:
		mov	ax,1			; invalid memory

v_exit:
		pop	di			; restore registers
		pop	si
		pop	ds
		pop	bp
		ret

_PhysToVirt	ENDP

;========================================================================

reqPak_frame	STRUC
		dw	?			; bp
		dw	?			; return address
prQueue		dw	?			; head of request packet queue
prReqPak	dd	?			; pointer to request packet
reqPak_frame	ENDS

;------------------------------------------------------------------------

_PullReqPacket	PROC	NEAR

		push	bp			; save bp
		mov	bp,sp			; get base of stack

		push	ds			; save registers
		push	si

		mov	ax,DGROUP		; data segment
		mov	ds,ax

		mov	si,prQueue[bp]		; head of request packet queue
		cmp	DPTR ds:[si],0		; check if zero
		jz	pull_none

		mov	dl,PULL_REQ_PAK		; get request packet

		cli				; must be protected
		call	DevHelp			; call kernel
		sti				; ok for ints now
		jc	pull_none

		lds	si,prReqPak[bp]		; pointer to request packet pointer
		mov	WPTR [si],bx		; return request packet
		mov	ax,es
		mov	WPTR [si+2],ax

		xor	ax,ax			; found packet

		pop	si			; restore registers
		pop	ds
		pop	bp
		ret

pull_none:
		lds	si,prReqPak[bp]		; pointer to request packet pointer
		mov	WPTR [si],0		; return NULL
		mov	WPTR [si+2],0

		mov	ax,1			; no packet returned

		pop	si			; restore registers
		pop	ds
		pop	bp
		ret
		
_PullReqPacket	ENDP

;========================================================================

_PushReqPacket	PROC	NEAR

		push	bp			; save bp
		mov	bp,sp			; get base of stack

		push	ds			; save registers
		push	si

		mov	ax,DGROUP		; data segment
		mov	ds,ax

		mov	si,prQueue[bp]		; head of request packet queue
		les	bx,prReqPak[bp]		; request packet to push
		mov	dl,PUSH_REQ_PAK		; put request packet on queue
		cli				; must be protected
		call	DevHelp			; call kernel
		sti				; ok for ints now

		xor	ax,ax			; can't fail

		pop	si			; restore registers
		pop	ds
		pop	bp
		ret

_PushReqPacket	ENDP

;========================================================================

_ProtToReal	PROC	NEAR

		push	ds			; save registers

		mov	ax,DGROUP		; data segment
		mov	ds,ax

		mov	dl,PROT_TO_REAL		; switch to protected mode

		call	DevHelp			; call kernel
		jc	pr_exit			; was the call successful?

		xor	ax,ax			; successful

pr_exit:
		pop	ds			; restore registers
		ret

_ProtToReal	ENDP

;========================================================================					

_RealToProt	PROC	NEAR

		push	ds			; save registers

		mov	ax,DGROUP		; data segment
		mov	ds,ax

		mov	dl,PROT_TO_REAL		; switch to real mode

		call	DevHelp			; call kernel
		jc	rp_exit			; was the call successful?

		xor	ax,ax			; successful

rp_exit:
		pop	ds			; restore registers
		ret

_RealToProt	ENDP

;========================================================================					

stack_frame	STRUC
		dw	?			; bp
		dw	?			; return address
stackData	dd	?			; stack data
stack_frame	ENDS

;------------------------------------------------------------------------

_StackUsage	PROC	NEAR

		push	bp			; save bp
		mov	bp,sp			; get base of stack

		push	ds			; save registers

		mov	ax,DGROUP		; data segment
		mov	ds,ax

		lds	bx,stackData[bp]	; stack data

		mov	dl,STACK_USAGE		; register stack usage

		call	DevHelp			; call kernel
		jc	su_exit			; was the call successful?

		xor	ax,ax			; successful

su_exit:
		pop	ds			; restore registers
		pop	bp
		ret

_StackUsage	ENDP

;========================================================================					

run_frame	STRUC
		dw	?			; bp
		dw	?			; return address
runEvent	dd	?			; event id
run_frame	ENDS

;------------------------------------------------------------------------

_Run		PROC	NEAR

		push	bp			; save bp
		mov	bp,sp			; get base of stack

		push	ds			; save registers

		mov	ax,DGROUP		; data segment
		mov	ds,ax

		mov	bx,WPTR runEvent[bp]	; event id
		mov	ax,WPTR runEvent+2[bp]

		mov	dl,RUN			; run thread

		call	DevHelp			; call kernel

		pop	ds			; restore registers
		pop	bp
		ret

_Run		ENDP

;========================================================================					

setIRQ_frame	STRUC
		dw	?			; bp
		dw	?			; return address
sIRQProc	dd	?			; intr routine
sIRQLevel	dw	?			; IRQ level
sIRQFlag	dw	?			; shareable flag
setIRQ_frame	ENDS

;------------------------------------------------------------------------

_SetIRQ		PROC	NEAR

		push	bp			; save bp
		mov	bp,sp			; get base of stack

		push	ds			; save registers

		mov	ax,DGROUP		; data segment
		mov	ds,ax

		mov	ax,WPTR sIRQProc[bp]	; offset of intr procedure
		mov	bx,sIRQLevel[bp]	; IRQ level

		mov	dx,sIRQFlag[bp]		; shareable flag
		shl	dx,8			; adjust value

		mov	dl,SET_IRQ		; register intr routine

		call	DevHelp			; call kernel
		xor	ax,ax
		jnc	si_exit

		mov	ax,1			; interrupt routine not registered

si_exit:
		pop	ds			; restore registers
		pop	bp
		ret

_SetIRQ		ENDP

;========================================================================					

unIRQ_frame	STRUC
		dw	?			; bp
		dw	?			; return address
uIRQLevel	dw	?			; IRQ level
unIRQ_frame	ENDS

;------------------------------------------------------------------------

_UnSetIRQ	PROC	NEAR

		push	bp			; save bp
		mov	bp,sp			; get base of stack

		push	ds			; save registers

		mov	ax,DGROUP		; data segment
		mov	ds,ax

		mov	bx,uIRQLevel[bp]	; IRQ level

		mov	dl,UNSET_IRQ		; register intr routine

		call	DevHelp			; call kernel
		xor	ax,ax
		jnc	ui_exit

		mov	ax,1			; interrupt routine not registered

ui_exit:
		pop	ds			; restore registers
		pop	bp
		ret

_UnSetIRQ	ENDP

;========================================================================					

phys_frame	STRUC
		dw	?			; bp
		dw	?			; return address
physPtr		dd	?			; virtual address
physAddr	dd	?			; pointer to memory
phys_frame	ENDS

;------------------------------------------------------------------------

_VirtToPhys	PROC	NEAR

		push	bp			; save bp
		mov	bp,sp			; get base of stack

		push	ds			; save registers
		push	si

		mov	ax,DGROUP		; data segment
		mov	es,ax

		lds	si,physPtr[bp]		; virtual address to convert

		mov	dl,VIRT_TO_PHYS		; convert to physical

		call	es:DevHelp		; call kernel
		jc	vp_exit

		lds	si,physAddr[bp]		; pointer to a long
		mov	WPTR ds:[si],bx		; LSW
		mov	WPTR ds:[si],ax		; MSW

		xor	ax,ax

vp_exit:
		pop	si			; restore registers
		pop	ds
		pop	bp
		ret

_VirtToPhys	ENDP

;========================================================================

_BreakPoint	PROC	NEAR

		int	3			; breakpoint
		ret

_BreakPoint	ENDP

;========================================================================

selLim_frame	STRUC
		dw	?			; bp
		dw	?			; return address
slSelector	dw	?			; selector
selLim_frame	ENDS

;------------------------------------------------------------------------

_SelectorLimit	PROC	NEAR

		push	bp   			; save bp
		mov	bp,sp			; get base of stack

		mov	ax,slSelector[bp]	; get selector
		lsl	ax,ax			; get selector limit

		pop	bp
		ret

_SelectorLimit	ENDP

;========================================================================

;USHORT  CopyPhysToVirt( VOID FAR *ptr, ULONG physAddr, USHORT length );
;USHORT  CopyVirtToPhys( ULONG physAddr, VOID FAR *ptr, USHORT length );
;USHORT  CopyPhysToPhys( ULONG destAddr, ULONG srcAddr, USHORT length );

;========================================================================

_TEXT		ENDS

;************************************************************************

		END
		