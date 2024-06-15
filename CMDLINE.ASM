		PAGE    85,132
        	TITLE   CMDLINE -- C startup code for CMDLINE device
        	.286P
;
;	cmdline.asm	Date=930103
;
;	C startup code for the CMDLINE driver
;
;

;========================================================================

BPTR		EQU     BYTE PTR                                         
WPTR		EQU     WORD PTR
DPTR		EQU     DWORD PTR

;========================================================================

		INCLUDE	stddd.inc		; OS/2 DD strucs

;========================================================================

		EXTRN   _CmdLineMain:NEAR	; device entry point

		PUBLIC  _CmdLineStrat

		PUBLIC	__acrtused		; no startup code wanted

;************************************************************************

_DATA		SEGMENT WORD PUBLIC 'DATA'
_DATA		ENDS

;************************************************************************

CONST		SEGMENT WORD PUBLIC 'CONST'
CONST		ENDS

;************************************************************************

_BSS		SEGMENT WORD PUBLIC 'BSS'
_BSS		ENDS

;************************************************************************

c_common	SEGMENT PUBLIC 'BSS'
c_common	ENDS

;************************************************************************

_END_DS		SEGMENT PUBLIC 'BSS'
_END_DS		ENDS

;************************************************************************

DGROUP		GROUP	CONST, _BSS, _DATA, c_common, _END_DS

;************************************************************************

_TEXT		SEGMENT WORD PUBLIC 'CODE'
		ASSUME  cs:_TEXT, ds:DGROUP, es:NOTHING, ss:NOTHING

;========================================================================
					
_CmdLineStrat	PROC	FAR			; entry point for strategy proc

__acrtused:					; no startup code wanted
		push	es			; push request packet on stack
		push	bx

		call	_CmdLineMain		; call the device entry point

		pop	bx			; restore the request packet
		pop	es

		mov	WPTR es:pktStatus[bx],ax; return status
					
		ret				; return to the kernel

_CmdLineStrat	ENDP

;========================================================================

_TEXT		ENDS

;************************************************************************

		END
