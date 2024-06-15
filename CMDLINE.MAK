#
#	cmdline.mak	Date=930103
#
#	generic poly-make makefile for exes
#

#----------------------------------------------------------------------

EXE = cmdline.sys

OBJS = cmdline.obj cmdmain.obj devhlp.obj devstr.obj devsupp.obj 

#MAKEFILE = cmdline.mak

DEFFILE = cmdline.def

LIBS = os2.lib slibce.lib

#----------------------------------------------------------------------

# build options

COPTIONS = -Asnw -G2s -Oilt -Zp -Zl -W3
CDEBUG   = 

LOPTIONS = /map /noi /nod
LDEBUG   = 

AOPTIONS = -Ml
ADEBUG   = 

#--------------------------------------------------------------------

# rules

ALL:		$(EXE)
		
$(EXE):		$(OBJS) $(MAKEFILE) $(DEFFILE)

.obj.sys:
        $(LINK) <@<
$[s," +\n",$[m,*.obj,$**]]
$@
$* $(LOPTIONS)
$(LIBS)
$(.PATH.def)\$(DEFFILE);
<

#----------------------------------------------------------------------

# dependencies

cmdline.obj:		cmdline.asm

cmdmain.obj:		cmdmain.c

#----------------------------------------------------------------------
