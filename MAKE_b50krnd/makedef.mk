SHELL = /bin/bash	

#BUILD_CONECTION?= conected
HEADMODULE_DIR = $(VIEW_ROOT)/$(HEADMODULE)
HEADMODULE_SRC_DIR = $(HEADMODULE_DIR)/source

ACTION_FILE = $(COMMON_MAKEFILE_DIR)/makeact.mk

COMMON_DIR = $(VIEW_ROOT)/Common
COMMON_SRC_DIR = $(COMMON_DIR)/source
COMMON_LIB_DIR = $(COMMON_DIR)/$(BASIC_LIB_DIR)/$(INNER_DIRS)

BASIC_LIB_DIR = lib
BASIC_OBJ_DIR = objs
BASIC_DEP_DIR = deps

LIB_DIR?= $(HEADMODULE_DIR)/$(BASIC_LIB_DIR)/$(INNER_DIRS)
#INNER_DIRS = $(OSTYPE)-$(BUILDTYPE)/$(BUILD_CONECTION)
INNER_DIRS?= $(OSTYPE)-$(BUILDTYPE)
OBJ_DIR?= $(BASIC_OBJ_DIR)/$(INNER_DIRS)
DEP_DIR?= $(BASIC_DEP_DIR)/$(INNER_DIRS)
TMPSRCS?= $(foreach SUBDIR, $(VPATH),$(wildcard $(SUBDIR)/*.cpp)) \
       $(foreach SUBDIR, $(VPATH),$(wildcard $(SUBDIR)/*.c)) \
       $(foreach SUBDIR, $(VPATH),$(wildcard $(SUBDIR)/*.pc))
OBJS?= $(addprefix $(OBJ_DIR)/, $(addsuffix .o, $(basename $(notdir $(SRCS)))))
DEPS?= $(addprefix $(DEP_DIR)/,$(addsuffix .d, $(basename $(notdir $(SRCS)))))
TMPS?= $(foreach SUBDIR, $(VPATH),$(wildcard $(SUBDIR)/*~*)) \
	$(foreach SUBDIR, $(VPATH),$(wildcard $(SUBDIR)/*\#*)) \
	$(foreach SUBDIR, $(VPATH),$(wildcard $(SUBDIR)/core))  
EXTERNALS += $(foreach EXTERNAL, $(EXTS), $($(EXTERNAL)_VER))

CXXFLAGS += $(foreach EXTERNAL, $(EXTERNALS), $(addprefix -D_, $(subst .,_,$(subst -,_,$(EXTERNAL)))))

SRCS?= $(filter-out ./$(MODSRC) $(FOUT) , $(TMPSRCS))

VPATH += .

LABEL_VERSION?= unknown

CFLAGS += -D$(HEADMODULE)# \
#	  -DVERSION=\"$(LABEL_VERSION)\" 

#APXSFLAGS += -D$(HEADMODULE)

CXXFLAGS += $(CFLAGS)

INCFLAGS += $(sort $(addprefix -I, \
		. \
		$(HEADMODULE_SRC_DIR))) # \
#		$(COMMON_SRC_DIR) ))

CXXINCFLAGS += $(INCFLAGS)

LIBFLAGS += $(sort $(addprefix -L, \
	     $(LIB_DIR) )) 

#LIBFLAGS += $(subst independent,conected,$(LIBFLAGS1)) 

#========================== ESTETICS ======================================
INDENT = "**********"
TAB = "	"
define START
@echo $(TAB) $(INDENT) $(BG_DBLUE)Building \'$(SUBMODULE)\' [$(BUILDTYPE)] On $(OSTYPE)$(BG_ORIGINAL) $(INDENT)
endef

define END
@echo $(TAB) $(INDENT) $(BG_DBLUE)\'$(SUBMODULE)\' [$(BUILDTYPE)] Built Succcesfully$(BG_ORIGINAL) $(INDENT)
endef


#ifneq ($(EMACS),t)
ifeq ($(EMACS),t)
#BG_DBLUE = "[44m"
BG_DBLUE =  "[44m"
BG_RED = "[41m"
BG_BLUE = "[46m"
BG_GREEN ="[42m"
BG_BROWN = "[43m"
#BG_ORIGINAL = "[49m"
BG_ORIGINAL = "[40m"
BG_PINK = "[45m"
BG_TRY = "[45m"

FG_RED ="[31m"
FG_BLUE = "[36m"
FG_GREEN ="[32m"
FG_BROWN ="[33m"
FG_ORIGINAL ="[39m"
endif
#========================== END ESTETICS ==================================

#=============================== STAND_ALONE ==============================
STAND_ALONE?= no
ifeq ($(STAND_ALONE),yes)
VPATH += ..

#CFLAGS += -DSTAND_ALONE \
#	  -DSTANDALONE

#BUILD_CONECTION = independent
LIB_DIR := $(LIB_DIR)/stand-alone
LIBS += $(STANDALONE_OSTYPE_LIBS)

endif

#=============================== END STAND_ALONE ==========================

#=============================== BUILDTYPE ================================
# unless entered the BUILDTYPE by target the build type is as the last BUILDTYPE used or debug if the first time make is used in this directory 
LAST_BUILDTYPE = $(shell \
		   if [ ! -e .lastBuildType ]; \
	 	   then \
			echo debug > .lastBuildType; \
		   fi; \
		   cat .lastBuildType ;)


CXX = $(CXX_COMPILER)
CC = $(CC_COMPILER)

# defining BUILDTYPE as the target entered
ifeq (,$(findstring $(MAKECMDGOALS), debug|release|insure))
BUILDTYPE = $(LAST_BUILDTYPE)
else
BUILDTYPE = $(MAKECMDGOALS)
endif

ifeq ($(BUILDTYPE),insure)
CXX_COMPILER = insure
CC_COMPILER = insure
else
ifeq ($(BUILDTYPE),debug)
CFLAGS += -g \
	  $(DEBUG_CFLAGS)
endif #(debug)
endif #(insure)


#=========================== END BUILDTYPE ================================

#============================= LINUX ======================================
ifeq ($(OSTYPE),linux)

DEP_FLAGS += -MM
CXX_COMPILER?= g++
CC_COMPILER?= gcc

#ifeq ($(BUILDTYPE),debug)
#CFLAGS += -Wall
#endif #(debug)

CFLAGS += -DLINUX=2 \
	  -D_GNU_SOURCE
#	  -D_STLP_NO_CSTD_FUNCTION_IMPORTS


DEBUG_CFLAGS +=	-Wall

#INCFLAGS += 

LDFLAGS	+= -shared -fpic

LDAPLIB = ldap30

endif # (linux)
#============================= END LINUX ==================================

#============================= SOLARIS ====================================
ifeq ($(OSTYPE),solaris)


########################################
# list of the modules that don't use stlport in solaris
ifeq ($(HEADMODULE),$(findstring $(HEADMODULE),alert|ADM|WMI|Manager|PushProxy|UserDBServer))
USE_STLPORT-4.5 = no
#export EXTERNALS += STLPORT
endif
########################################

DEP_FLAGS += -xM1

CXX_COMPILER = CC
CC_COMPILER = cc

#LDAPLIB = ldapssl41
LDAPLIB = ldap50

########################################
# definishions for finding memory leaks
# FMLCXX = purify $(CXX)
# FMLCC = purify $(CC)
########################################

#CFLAGS += -DSOLARIS=8 \
#	   $(SOLARIS_CFLAGS)

SOLARIS_CFLAGS = -xarch=v9

#CXXFLAGS += 	-instances=static 

#APXSFLAGS += -DSOLARIS=8 

#OSTYPE_LIBS = -liostream \
#		-lCstd \
#		-lCrun 


#STANDALONE_OSTYPE_LIBS = -lsocket\
#			 -lnsl \


LIBS += $(OSTYPE_LIBS)

LDFLAGS	+= -G \
	   -Kpic \
	   -xarch=v9  \
	  -L/usr/lib/sparcv9 

#OSLIBS = /usr/lib/libCrun.so.1 /usr/lib/libCstd.so.1 /usr/lib/libiostream.so.1

endif #(solaris)
#============================= END SOLARIS ================================

#============================ EXTERNALS ===================================
# external directories in use

#The externals used for each module are declared in their own makefile.
# Here we add thedeclared EXTERNALS to all the places needed

# EXTRENAL LIST :
#--------------- 
# XERCES1.3 
# XERCES1.5.1
# XERCES1.5.2
# XERCES2.2
# ICU2.2 
# ICU1.6
# XML2 
# MM1.1.3 
# PG 
# APACHE1.3.26 
# MIMEPP 
# LDAP 
# XMIME
# ACE5.3
# SENDMAIL8.12.6


# export EXTERNALS += LDAP

ifneq ($(USE_STLPORT-4.5),no)
export EXTERNALS += STLPORT-4.5
else
export EXTERNALS += LDAP
endif

#EXT_LIBFLAGS += -L$(EXTERNALS_DIR)/$(BASIC_LIB_DIR)/$(OSTYPE)
EXT_LIBFLAGS += $(sort $(foreach EXTERNAL, $(EXTERNALS), \
		$(addprefix -L,$($(EXTERNAL)_LIB_DIR)))  )
EXT_INCFLAGS += $(sort $(foreach EXTERNAL, $(EXTERNALS), \
		$(addprefix -I,$($(EXTERNAL)_INC_DIR)))  )
EXTLIBS += 	$(sort $(foreach EXTERNAL, $(EXTERNALS), \
		$(addprefix -l,$($(EXTERNAL)LIBS))))

LIBS += $(EXTLIBS)
LIBFLAGS += $(EXT_LIBFLAGS) 


CXXINCFLAGS += $(filter -I$(STLPORT-4.5_INC_DIR),$(EXT_INCFLAGS))
INCFLAGS += $(filter-out -I$(STLPORT-4.5_INC_DIR),$(EXT_INCFLAGS))


#EXTERNALS_DIR?= $(VIEW_ROOT)/product/bscs700/externals
EXTERNALS_DIR?= $(VIEW_ROOT)/externals
#EXTERNALS_DIR?= $(VIEW_ROOT)/product/core/src
UDRLIB=$(BSCS_CORE_SRC)/udrlib
DXLIB=$(BSCS_CORE_SRC)/dxlib

STLPORT_DIR?= $(EXTERNALS_DIR)/STLport
STLPORT-4.5_DIR?= $(STLPORT_DIR)/STLport-4.5/$(OSTYPE)
STLPORT-4.5_INC_DIR = $(STLPORT-4.5_DIR)/include/stlport

ACE_DIR?= $(EXTERNALS_DIR)/ACE
ACE5.3_DIR?= $(ACE_DIR)/ACE-5.3-64bit/ACE_wrappers
ACE5.3_INC_DIR = $(ACE5.3_DIR)
ACE5.3_LIB_DIR = $(ACE5.3_DIR)/ace
ACE5.3LIBS = 	ACE \
		socket \
		dl \
		nsl \
		gen \
		posix4

IFCWrapper_DIR?= $(EXTERNALS_DIR)/IFCWrapper
IFCWrapper_INC_DIR = $(IFCWrapper_DIR)/include
IFCWrapper_LIB_DIR = $(IFCWrapper_DIR)/lib
IFCWrapperLIBS = iconv \
		charset \
		z \
		pthread \
		m \
		curl \
		ssl \
		crypto \
		xml2	\
		ifcwrapper

# the only reason to use XML2 is if you are using hotmail
ifeq (IFCWrapper,$(findstring IFCWrapper,$(EXTERNALS)))
CFLAGS+= -O -xcode=pic13
endif

ifeq (STLPORT-4.5,$(findstring STLPORT-4.5,$(EXTERNALS)))
STLPORT_CFLAGS += -D_STLP_HAS_NO_NEW_IOSTREAMS \
		 -D_STLP_NO_OWN_IOSTREAMS

ifneq ($(SHOULD_USE_THREADS),no)
	STLPORT_CFLAGS += -D_STLP_THREADS
endif



CXXFLAGS += $(STLPORT_CFLAGS)

#CXXFLAGS += -DXALAN_NO_NAMESPACES
endif

ifeq (APACHE,$(findstring APACHE,$(EXTS)))
	USE_APACHE = yes
else
	USE_APACHE = no
#	CFLAGS += -DNO_APACHE 
endif

ifeq (ACE5.3,$(findstring ACE5.3,$(EXTERNALS)))
#CFLAGS += -DACE_USES_OLD_IOSTREAMS -DACE_LACKS_STRTOUL

#this is orig
#CXXFLAGS += -mt   -instances=explicit -DACE_HAS_EXPLICIT_TEMPLATE_INSTANTIATION -DSUN_CC_HAS_PVFC_BUG -DACE_HAS_EXCEPTIONS -D__ACE_INLINE__

CXXFLAGS += -mt   


#INCFLAGS += 
LIBFLAGS +=
LDFLABS += -xildoff
endif

#============================ END EXTERNALS ===============================

#============================ RATING MODULES ==============================


#RP_DIR?= $(BSCS_BINDIR)
RP_DIR?= $(EXTERNALS_DIR)/RP

#RP_DIR?= $(BSCS_BINDIR)


ALLRPLIBS = $(shell rplibs.pl $(RP_DIR)/lib)
DXLIBS = dx
UDRLIBS = udr
BALLIBS = bal
UDRINTLIBS = udrInt
BATPPLIBS = bat++
DTALIBS = dta
MPCOMMONLIBS = mpcommon
SHMADMLIBS = shmadm
FIOTLIBS = \
	dx \
	bal \
	mpcommon \
	shmadm   \
	bat++  \
#	bat   \
	udr   \
	dta \
	clntsh

RP_INCFLAGS +=  -I$(ORACLE_HOME)/rdbms/demo
RP_INCFLAGS +=  -Iinclude
RP_INCFLAGS +=  -I$(RP_DIR)/include
RP_INCFLAGS +=  -I$(UDRLIB)/include
RP_INCFLAGS +=  -I$(DXLIB)/include

ifeq ($(BUILDTYPE),debug)
RP_LIBFLAGS += -L$(RP_DIR)/lib
else
RP_LIBFLAGS += -L$(BSCS_BINDIR)
endif

RPSLIBS += $(foreach RATING,$(RPS),$(addprefix -l,$($(RATING)LIBS)))

RP_DFLAGS += 	-Dsun5 \
		-D__SUN \
		-Dsun \
		-Dsparc \
		-DSunOS53 \
		-DCONFIG_64BIT \
		-DNEW_ANSI \
		-D__EXTENSIONS__ \
		-D_POSIX_4SOURCES \
		-DG_SUN \
		-DG_EH \
		-DG_ANSICPP \
		-DG_LONGSIZE=64 \
		-DORACLE_DB_BRAND \
		-DTT_64BIT \
		-DTTEXCEPT
RP_CFLAGS += $(RP_DFLAGS) -xarch=v9

RP_LDFLAGS += 	-D__SUN \
		-Dsun \
		-Dsparc \
		-DSunOS53 \
		-DCONFIG_64BIT \
		-DNEW_ANSI \
		-D__EXTENSIONS__ \
		-I/opt/SUNWspro/WS6U2/include/CC/Cstd \
		-L/$(HOST)/app01/oracle/product/8.1.7/lib64 \
		-xarch=v9 \
		-mt \
		-L/opt/SUNWspro/WS6U2/lib/v9 \
		-L/usr/lib/64

LIBS += $(RPSLIBS)
LIBFLAGS += $(RP_LIBFLAGS) 
INCFLAGS += $(RP_INCFLAGS)
LDFLAGS += $(RP_LDFLAGS)
CFLAGS += $(RP_CFLAGS)




#============================ END RATING MODULES ==========================

#============================ DEPS ========================================
# defines each submodule on all the other submodules it is depended on

# the file containing the depended submodules. 
#is filled by runtime by the .d files
SM_PROFILE = $(DEP_DIR)/sm_profile

# the list of the depended Submodules
BUILDSM_TMP = $(filter-out $(CURDIR), \
		$(shell \
	      	if [ -e $(SM_PROFILE) ]; \
		then \
		cat $(SM_PROFILE); \
		fi))

BUILDSM += $(BUILDSM_TMP)

MTXLIBS = $(addprefix -l,$(notdir $(filter-out $(MIMEPP_DIR),$(BUILDSM))))

#LIBS_WAS = $(LIBS)
#LIBS = $(MTXLIBS) 
#LIBS += $(LIBS_WAS)
#============================ END DEPS ====================================

#=============================== COMPILE =================================
ECHO_COMPILE?= @echo $(INDENT) $(BG_BLUE)Compiling $<$(BG_ORIGINAL)...
ECHO_DEP?= @echo $(INDENT) $(BG_RED)Creating ${@F}$(BG_ORIGINAL)\...
ECHO_CLEAN?= echo $(TAB) $(INDENT) $(BG_BROWN)Cleaning \'$(SUBMODULE)\' [$(BUILDTYPE)] On $(OSTYPE)$(BG_ORIGINAL) $(INDENT)
FULLCLEAN = rm -rf $(BASIC_DEP_DIR) \
		   $(BASIC_OBJ_DIR) \
		   core \
		   $(ALLTARGET)

BASECC_COMPILE?= $(CC) -c $(CFLAGS) $(INCFLAGS) $<
BASECXX_COMPILE?= $(CXX) -c $(CXXFLAGS) $(CXXINCFLAGS) $<
CXX_COMPILE?=  $(BASECXX_COMPILE) -o $@
CC_COMPILE?=   $(BASECC_COMPILE) -o $@ 

PC_TEMPNAME?= $(patsubst %.pc,%.cc, $<)
BASEPC_COMPILE?= $(ORACLE_HOME)/bin/proc `echo $(RP_DFLAGS) $(INCFLAGS) | sed -e 's/-I/INCLUDE=/g' -e 's/-D[^ ]=[^ ]*//g' -e 's/-D\([^ ]*\)/DEFINE=\1/g'` code=ansi_c maxopencursors=20 select_error=no  USERID=rpe/sysadm123 SQLCHECK=SEMANTICS dbms=v8 char_map=CHARZ code=CPP sys_include=/opt/SUNWspro/WS6U2/include/CC/std parse=PARTIAL lines=yes iname=$< oname=$(PC_TEMPNAME)

PC_COMPILE1?= rm $(PC_TEMPNAME) ; $(BASEPC_COMPILE) 
PC_COMPILE2?= $(CXX) -c $(CXXFLAGS) $(CXXINCFLAGS) $(PC_TEMPNAME) -o $@

DEPCFLAGS = $(filter-out  $(SOLARIS_CFLAGS),$(CFLAGS)) 
DEPCXXFLAGS = $(filter-out  $(SOLARIS_CFLAGS),$(CXXFLAGS)) 

define DEPCC_COMPILE
	#@echo $@
	set -e; $(CC_COMPILER) -c $(DEPCFLAGS) $(INCFLAGS) $< $(DEP_FLAGS) | \
	sed 's|$(*F)\.o[ :]*|$(OBJ_DIR)\/$(*F).o $(DEP_DIR)\/$(@F) : |g' > \
	$@; [ -s $@ ] || rm -f $@
endef

define DEPCXX_COMPILE
	#@echo $(CURDIR)/$@
	set -e; $(CXX_COMPILER) $(DEPCXXFLAGS) $(CXXINCFLAGS) $< $(DEP_FLAGS)| \
	sed 's|$(*F)\.o[ :]*|$(OBJ_DIR)\/$(*F).o $(DEP_DIR)\/$(@F) : |g' > \
	$@; [ -s $@ ] || rm -f $@
endef
#=============================== END COMPILE =============================

#================================= TARGETS ===============================
MODTYPE = mod_
ifeq ($(firstword $(subst $(MODTYPE),$(MODTYPE) ,$(SUBMODULE))),$(MODTYPE))
SMTYPE = 
else
SMTYPE = lib
endif

STAT_LIBRARY?= $(LIB_DIR)/$(SMTYPE)$(SUBMODULE).a
DYN_LIBRARY?= $(LIB_DIR)/$(SMTYPE)$(SUBMODULE).so


# a default target may be changed in the submoduels makefile
#EXE_TARGET?= test$(SUBMODULE)
EXE_TARGET?= $(LIB_DIR)/$(SUBMODULE)
ALLTARGET = $(STAT_LIBRARY) $(DYN_LIBRARY) $(EXE_TARGET)
#================================= END TARGETS ============================


#============================ DEPENDENCY MODULES  ===================================
# DEPMODULES = 

DEP_INCFLAGS += $(sort $(foreach DEP, $(DEPMODULES), \
		$(addprefix -I,$($(DEP)_INC_DIR)))  )

DEP_MAKE_DIRS = $(foreach DEP, $(DEPMODULES), $($(DEP)_MAKE_DIRS))

INCFLAGS += $(DEP_INCFLAGS)

WMI_KERNEL_DIR = $(VIEW_ROOT)/WMI/source/WMIkernel
WMI_KERNEL_INC_DIR = $(WMI_KERNEL_DIR)
WMI_KERNEL_MAKE_DIRS = $(WMI_KERNEL_DIR)


MANAGER_KERNEL_DIR = $(VIEW_ROOT)/Manager/source/ManagerKernel
MANAGER_KERNEL_INC_DIR = $(MANAGER_KERNEL_DIR)
MANAGER_KERNEL_MAKE_DIRS = $(MANAGER_KERNEL_DIR)

#============================ CONF FILE ===================================
CONF_EXT_VERS = $(foreach EXT, $(MODULE_EXTS), $($(EXT)_VER))
EXT_LIBS_FULLPATH = $(MODULE_ADDITIONAL_LIBS) $(foreach EXT, $(CONF_EXT_VERS), $($(EXT)LIBS_FULL))
EXT_LIBS_NAMES = $(foreach FULLPATH, $(EXT_LIBS_FULLPATH), $(shell echo $(FULLPATH) | sed "s/.*\///"))
CONF_LINES_EXT = $(foreach EXT, $(EXT_LIBS_NAMES), LoadFile+$(HEADMODULE)_libs/$(EXT))

CONF_HEADMODULE_SUBMODULES = $(foreach MODULE, $(HEADMODULE_SUBMODULES), $(shell echo $(MODULE) | sed "s/.*\///"))
CONF_COMMON_SUBMODULES = $(foreach MODULE, $(COMMON_SUBMODULES), $(shell echo $(MODULE) | sed "s/.*\///"))
CONF_LINES_HEADMODULE = $(foreach MODULE, $(CONF_HEADMODULE_SUBMODULES), $(if $(filter $(APACHE_MODULES), $(MODULE)), LoadModule+$(MODULE)_module+$(HEADMODULE)_libs/mod_$(MODULE).so, LoadFile+$(HEADMODULE)_libs/lib$(MODULE).so))
CONF_LINES_COMMON= $(foreach MODULE, $(CONF_COMMON_SUBMODULES), $(if $(filter $(APACHE_MODULES), $(MODULE)), LoadModule+$(MODULE)_module+$(HEADMODULE)_libs/mod_$(MODULE).so, LoadFile+$(HEADMODULE)_libs/lib$(MODULE).so))
CONF_LINES_OSLIBS= $(foreach OSLIB, $(OSLIBS), LoadFile+$(OSLIB))

CONF_FILE = $(LIB_DIR)/$(HEADMODULE)_libs.conf

