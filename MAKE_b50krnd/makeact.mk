#########################################################################
# this file contains the general makefile targetsused by all indevidual 
# makefiles

ifeq ($(TARGET_TYPE),lib)
all: start dirs do
else
all: start dirs lastBuildType sm objs target end
endif

# contains phoney target. use makefile targets and not file targets
.PHONY: all $(BUILDTYPE) objs deps clean cleanall dirs Test lib exe target start end force $(BUILDSM) subdirs lastBuildType fullclean


ifeq ($(STAND_ALONE),no)
do: lastBuildType objs target end 
else
do:lastBuildType sm buildsm objs target end
endif


#================================= SUBMODULES =============================
# targets when a makefile is run by another makefile as a submodule

# the main target of a submodule 
assub: start dirs do 

# a target to create the sm_profile file which contains all the submodules
# of a module recursevely
sm: deps $(SM_PROFILE)

# returns the name of the submodules of a module
subnames: 
	@DepBB $(VIEW_ROOT) $(DEP_DIR) basename


# a target rule for crearting the sm_profile file
$(SM_PROFILE): dirs
	getAllSubs.pl $(VIEW_ROOT) $(HEADMODULE) "$(HEADMODULE_MODULES)" "$(COMMON_MODULES)" $(SUBMODULE) $(CURDIR)/$(DEP_DIR) fullPath > $@


# the target that builds all the submodule of the module
buildsm: $(BUILDSM)

# the target rule that enters the directory of each submodule and runs "make"
$(BUILDSM): $(SM_PROFILE)
	cd $@ ;$(MAKE)  STAND_ALONE=no BUILDTYPE=$(BUILDTYPE) TARGET_TYPE=lib assub 

#================================= END SUBMODULES =========================

#================================= BUILDTYPE ==============================
# saves the BUILDTYPE of this make for the next make to run as default
lastBuildType:
	echo $(BUILDTYPE) > .lastBuildType

# when you enter the BUILDTYPE as target i.e. "make release"
$(BUILDTYPE) : all
#================================= TARGETS ================================

# defines the type of output we want the "make" to create 
#ifdef ($(TARGET_TYPE))

ifeq ($(STAND_ALONE),no)
target: lib
else
target: exe
endif

#else
#target: $(TARGET_TYPE)
#endif

# creates a dynamic library and a static library
ifeq ($(LIBTYPE),static)
lib: statlib
else
lib: dynlib
endif

# creats a dynamic libraray "*.so"
dynlib: $(DYN_LIBRARY) 

# creates a static (archive) library "*.a"
statlib: $(STAT_LIBRARY) 

# creates an executabel
exe: $(EXE_TARGET)

# build the object files "*.o"
objs: $(OBJS)

# creates the dependency files "*.d"
deps: dirs $(DEPS)

# deppsall - create dependency files of all the sub-modules of the head-module
ifneq ($(USE_DEPSALL),no)
depsall: dirs
	cd $(HEADMODULE_SRC_DIR); $(MAKE)  STAND_ALONE=$(STAND_ALONE) USE_APACHE=$(USE_APACHE) deps
else
depsall: ;
endif

# rule to create "*.d" files out of "*.cpp" files
$(DEP_DIR)/%.d: %.cpp 
	$(ECHO_DEP)
	$(DEPCXX_COMPILE)

# rule to create "*.o" files out of "*.cpp" files
$(OBJ_DIR)/%.o : %.cpp 	
	$(ECHO_COMPILE)
	$(CXX_COMPILE)

# rule to create "*.d" files out of "*.pc" files
$(DEP_DIR)/%.d : %.pc 	
	$(ECHO_DEP)
	$(DEPCXX_COMPILE)

# rule to create "*.o" files out of "*.pc" files
$(OBJ_DIR)/%.o : %.pc 	
	$(ECHO_COMPILE)
	$(PC_COMPILE1)
	$(PC_COMPILE2)

# rule to create "*.d" files out of "*.c" files
$(DEP_DIR)/%.d: %.c 
	$(ECHO_DEP)
	$(DEPCC_COMPILE)

# rule to create "*.o" files out of "*.c" files
$(OBJ_DIR)/%.o : %.c
	 @echo $(INDENT) $(BG_BLUE)Compiling $<$(BG_ORIGINAL)...	
	$(CC_COMPILE) 

# rule to create an "*.a" file out of "*.o" files
$(STAT_LIBRARY): $(OBJS)
	@echo $(INDENT) $(BG_GREEN)Linking  $(@F)$(BG_ORIGINAL)\...
	@echo location = $(@D)/$(@F)
	ar -r $@ $(OBJS)

# rule to create an "*.so" file out of "*.o" files
$(DYN_LIBRARY): $(OBJS)
	@echo $(INDENT) $(BG_GREEN)Linking $(@F)$(BG_ORIGINAL)\...
	@echo location = $(@D)/$(@F)
	$(CXX) -o $@ $(OBJS) $(LDFLAGS) $(LIBFLAGS) $(LIBS)
#	$(CXX) -o $@ $(OBJS) $(LDFLAGS) 

# rule to create an executabel file out of "*.o" files
$(EXE_TARGET): $(OBJS)
	@echo $(INDENT) $(BG_GREEN)Linking $@$(BG_ORIGINAL)\...
	@echo location = $(@D)/$(@F)
	$(CXX) $(CXXFLAGS) $(INCFLAGS) -o  $@ $(OBJS) $(LIBFLAGS) $(MTXLIBS) $(LIBS) 
#	$(CXX) $(CXXFLAGS) $(INCFLAGS) -o  $@ $(OBJS) $(LDFLAGS) $(LIBFLAGS) $(LIBS) 
	rm $(@F);  ln -s $(@D)/$(@F)
#================================= END TARGETS ============================

#================================= CLEAN ==================================
# cleans only the submodule the make is run from
clean: 
	@$(ECHO_CLEAN)
	rm -rf $(OBJ_DIR) $(DEP_DIR) $(TMPS) $(ALLTARGET)

# cleans all the submoduel of a module and the current module
# (will work only if sm_profile file exists)
cleanall: cleansubs clean

# cleans ALL the dirs and files created in a submodule by ANY use of "make"
smfullclean: 
	@echo $(INDENT) $(BG_BROWN)fullcleaning $(SUBMODULE)$(BG_ORIGINAL)
	$(FULLCLEAN)

# will smfullclean all the submodule of the head-module
fullclean: 
	cd $(HEADMODULE_SRC_DIR); $(MAKE) smfullclean


#cleans all the submodules of a module according to the last build
cleansubs:
	$(foreach SUBDIR, $(BUILDSM) , cd $(SUBDIR) ; \
	$(MAKE)  STAND_ALONE=no USE_APACHE=$(USE_APACHE) BUILDTYPE=$(BUILDTYPE) clean;)

#================================= END CLEAN ==============================

#================================= PREPARE ================================
# dirs where files created by make are put in
dirs:
	@mkdir -p $(OBJ_DIR) $(DEP_DIR) $(LIB_DIR)

# synchronizing between the hardware clock and the software clock 
time:
	sudo /sbin/hwclock --systohc
#	/sbin/hwclock --set "--date=$(DATE)"
#	/sbin/hwclock --hctosys

#================================= END PREPARE ============================

#================================== BANNERS ===============================
start: 
	$(START)
end:
	$(END)
#============================== END BANNERS ===============================

Test: 
	@echo ++++++++++++++++++++
	@echo CFLAGS = $(CFLAGS)
	@echo CXXFLAGS = $(CXXFLAGS)
#	@echo SRCS = $(SRCS)
#	@echo OBJS = $(OBJS)
	@echo $(FG_GREEN)DEPS$(FG_ORIGINAL) = $(DEPS)
#	@echo TMPS = $(TMPS)
#	@echo STLPORTROOT = $(STLPORTROOT)
#	@echo CXX = $(CXX)
	@echo $(FG_GREEN)MAKECMDGOALS$(FG_ORIGINAL) = $(MAKECMDGOALS)
	@echo SUBMODULE = $(SUBMODULE)
	@echo BUILDTYPE = $(BUILDTYPE)
	@echo STAND_ALONE = $(STAND_ALONE)
	@echo DYN_LIBRARY = $(DYN_LIBRARY)
	@echo STAT_LIBRARY = $(STAT_LIBRARY)
	@echo EXE_TARGET = $(EXE_TARGET)
	@echo DEPSM = $(DEPSM)
	@echo MAKE = ${MAKE}
	@echo CLNSUBS = $(CLNSUBS)
	@echo MTXLIBS = $(MTXLIBS)
	@echo SRCS = $(SRCS)
	@echo $(FG_GREEN)BUILDSM$(FG_ORIGINAL) = $(BUILDSM)
	@echo OBJS = $(OBJS)
	@echo $(FG_GREEN)INCFLAGS$(FG_ORIGINAL) = $(INCFLAGS)
#	@echo $(FG_GREEN)CC_COMPILE$(FG_ORIGINAL) = $(CC_COMPILE)
#	@echo $(FG_GREEN)DEPCC_COMPILE$(FG_ORIGINAL) = $(DEPCC_COMPILE)
	@echo $(FG_GREEN)LDFLAGS$(FG_ORIGINAL) = $(LDFLAGS)
	@echo $(FG_GREEN)MODSRC$(FG_ORIGINAL) = $(MODSRC)
	@echo $(FG_GREEN)VPATH$(FG_ORIGINAL) = $(VPATH)
	@echo $(FG_GREEN)EXTERNALS$(FG_ORIGINAL) = $(EXTERNALS)
	@echo $(FG_BLUE)EXTS = $(EXTS)$(FG_ORIGINAL)
	@echo $(FG_BLUE)RPS = $(RPS)$(FG_ORIGINAL)		
	@echo $(FG_BLUE)LIBS = $(LIBS)$(FG_ORIGINAL)


#================================= INCLUDES ===============================
#****************** NOTE: MUST be last in the file ************************

ifeq (,$(findstring $(MAKECMDGOALS),clean| cleanall | fullclean ))
-include $(DEP_DIR)/*.d
else
#MAKE += clean
endif

#============================= END INCLUDES ===============================


