ACLOCAL_AMFLAGS = -I dists/autogen/m4
DISTCLEANFLAGS = *~ autoscan.log dists/autogen/*~

#################################################
# @PACKAGE_STRING@
# @configure_input@
#################################################

@SET_MAKE@
SHELL = /bin/sh

#################################################
# Standard definitions
#################################################

prefix      ?= @prefix@
exec_prefix ?= @exec_prefix@
bindir      ?= @bindir@
datarootdir ?= @datarootdir@
datadir     ?= @datadir@
libdir      ?= @libdir@
docdir      ?= @docdir@
pdfdir      ?= @pdfdir@
mandir      ?= @mandir@
# project root-dir (directory of configure script)
top_srcdir  ?= @top_srcdir@
# project src-dir (directory of the current Makefile)
srcdir      ?= @srcdir@

# file-type suffix of executables (e.g. ".exe" in windows)
EXEEXT ?= @EXEEXT@

#################################################
# Tools
#################################################

# recursive dir creation tool (mkdir -p)
MKDIR        ?= @MKDIR_P@
RM           ?= rm -f
RM_REC       ?= $(RM) -r

# install tool
INSTALL         ?= @INSTALL@
INSTALL_DATA    ?= @INSTALL_DATA@
INSTALL_PROGRAM ?= @INSTALL_PROGRAM@

#################################################
# General package configuration
#################################################

USDX_PACKAGE_NAME := @PACKAGE_NAME@
USDX_VERSION := @PACKAGE_VERSION@
USDX_TARNAME := @PACKAGE_TARNAME@

#################################################
# USDX Paths
#################################################

USDX_SRC_DIR   := $(top_srcdir)/src
USDX_GAME_DIR  := $(top_srcdir)/game
USDX_TOOLS_DIR := $(top_srcdir)/tools
USDX_BUILD_DIR := $(top_srcdir)/build
USDX_LIB_DIR   := $(USDX_SRC_DIR)/lib

INSTALL_DATADIR := $(datadir)/$(USDX_PACKAGE_NAME)

#################################################
# Binary name
#################################################

# name of executable
USDX_BIN_NAME ?= ultrastardx$(EXEEXT)
USDX_BIN := $(USDX_GAME_DIR)/$(USDX_BIN_NAME)

#################################################
# ProjectM
#################################################

PROJECTM_CWRAPPER_DIR := $(USDX_LIB_DIR)/projectM/cwrapper
USE_PROJECTM_CWRAPPER = @USE_PROJECTM_CWRAPPER@

#################################################
# Dependencies
#################################################

DEPS :=
@ifGNUmake@ifeq ($(USE_PROJECTM_CWRAPPER), yes)
@ifGNUmake@  DEPS += $(PROJECTM_CWRAPPER_DIR)
@ifGNUmake@endif

#################################################
# general targets
#################################################

##
# IMPORTANT:
# Always assure that this Makefile still works with the -jN 
# parameter set. This is important as Gentoo uses parallel 
# make (-j2) by default.
# If parallel execution is enabled you cannot rely on a 
# specific order the prerequisites are build. 
#
# Example:
#   target: dependency dependant
#
# will first build "dependency" and "dependant" afterwards with a
# sequential execution (-j1). With parallel execution "dependant"
# might be started before "dependency" is finished and make will
# crash.
#
# If it is not possible, add the virtual .NOTPARALLEL target.
# This will disable parallel execution for ALL targets.
##

BUILD_TARGETS = all debug release rebuild build
.PHONY: $(BUILD_TARGETS)
$(BUILD_TARGETS): all-deps
	$(MAKE) -C $(USDX_SRC_DIR) $@

.PHONY: all-deps
all-deps:
	@for dir in $(DEPS); do \
	  $(MAKE) -C "$${dir}" all; \
	done

.PHONY: clean-local
clean-local: clean-src clean-deps

.PHONY: clean-src
clean-src:
	$(MAKE) -C $(USDX_SRC_DIR) clean

.PHONY: clean-deps
clean-deps:
	@for dir in $(DEPS); do \
	  $(MAKE) -C "$${dir}" clean; \
	done

.PHONY: clean-game
clean-game:
	$(RM) $(USDX_GAME_DIR)/*.log
	$(RM) $(USDX_GAME_DIR)/*.db
	$(RM) $(USDX_GAME_DIR)/*.ini
	-rmdir $(USDX_GAME_DIR)/screenshots || echo "skipping $(USDX_GAME_DIR)/screenshots"
	-rmdir $(USDX_GAME_DIR)/playlists || echo "skipping $(USDX_GAME_DIR)/playlists"
	-rmdir $(USDX_GAME_DIR)/songs || echo "skipping $(USDX_GAME_DIR)/songs"

# just clean the game build data but no dependencies (libs, tools, ...)
.PHONY: mostlyclean-local
mostlyclean-local: clean-src

.PHONY: distclean-local
distclean-local: clean clean-game tidy
	$(RM) config.log config.status aclocal.m4 
	$(RM_REC) autom4te.cache || rmdir autom4te.cache
	$(RM) $(USDX_SRC_DIR)/config.inc link*.res
	$(RM) $(srcdir)/Makefile $(USDX_SRC_DIR)/Makefile $(PROJECTM_CWRAPPER_DIR)/Makefile

.PHONY: maintainer-clean-local
maintainer-clean-local: distclean

# remove temporary and backup files
.PHONY: tidy
tidy:
# FPC stuff
	find $(srcdir) -name "*.compiled" | xargs $(RM)
# Delphi stuff
	find $(srcdir) -name "__history" | xargs $(RM_REC)
	find $(srcdir) -name "*.identcache" -o -name "*.dcu" | xargs $(RM)
# Backup files
	find $(srcdir) -name "*~" -o -name "*.bak" -o -name "*.orig" | xargs $(RM)


#################################################
# auto-update
#################################################

.PHONY: Makefile-reconf
Makefile-reconf: $(srcdir)/Makefile.in $(USDX_SRC_DIR)/Makefile.in $(USDX_SRC_DIR)/config.inc.in $(PROJECTM_CWRAPPER_DIR)/Makefile.in config.status
	@echo "-----------------------------------"
	@echo "Performing reconfiguration..."
	./config.status
	@echo "-----------------------------------"

.PHONY: rerun_config_dot_status
rerun_config_dot_status: configure
	./config.status --recheck

.PHONY: reconf
reconf:
	$(SHELL) ./autogen.sh

#################################################
# install/uninstall
#################################################

##
# For information on directory and install conventions see
#   "info autoconf", Section 4.8.2. Installation Directory Variables
#                    Section 4.8.1, 4.8.3 and 4.8.4 
# Notes:
# - "make install" must not rebuild, so do not depend on all.
# - use the DESTDIR variable as prefix for installation directories, 
#   otherwise Gentoo will not be able to install as it uses a sandbox.
##

.PHONY: install-usdx
install-usdx: install-all
	@echo "--------------------------------"
	@echo "$(USDX_PACKAGE_NAME) installed."
	@echo "Start with: $(bindir)/$(USDX_BIN_NAME)"
	@echo "--------------------------------"

# strip binaries during install
.PHONY: install-usdx-with-strip
install-usdx-with-strip:
	$(MAKE) INSTALL_PROGRAM='$(INSTALL_PROGRAM) -s' \
                install

.PHONY: install-all
install-all: install-exec install-plugins install-data

.PHONY: install-exec-local
install-exec-local:
	$(MKDIR) "$(DESTDIR)$(bindir)"
	$(INSTALL_PROGRAM) "$(USDX_BIN)" "$(DESTDIR)$(bindir)"

# FPC target platform and processor
PPLATFORM  := @FPC_PLATFORM@
PPROCESSOR := @FPC_PROCESSOR@

.PHONY: install-plugins
install-plugins:
	$(MKDIR) "$(DESTDIR)$(INSTALL_DATADIR)/plugins"
	$(INSTALL) "$(USDX_GAME_DIR)/plugins"/* "$(DESTDIR)$(INSTALL_DATADIR)/plugins"

.PHONY: install-data-local
install-data-local:
	$(MAKE) RECURSIVE_SRC_DIR="$(USDX_GAME_DIR)/languages" \
            RECURSIVE_DST_DIR="$(DESTDIR)$(INSTALL_DATADIR)/languages" \
            install-data-recursive
	$(MAKE) RECURSIVE_SRC_DIR="$(USDX_GAME_DIR)/sounds" \
            RECURSIVE_DST_DIR="$(DESTDIR)$(INSTALL_DATADIR)/sounds" \
            install-data-recursive
	$(MAKE) RECURSIVE_SRC_DIR="$(USDX_GAME_DIR)/themes" \
            RECURSIVE_DST_DIR="$(DESTDIR)$(INSTALL_DATADIR)/themes" \
            install-data-recursive
	$(MAKE) RECURSIVE_SRC_DIR="$(USDX_GAME_DIR)/fonts" \
            RECURSIVE_DST_DIR="$(DESTDIR)$(INSTALL_DATADIR)/fonts" \
            install-data-recursive
	$(MAKE) RECURSIVE_SRC_DIR="$(USDX_GAME_DIR)/resources" \
            RECURSIVE_DST_DIR="$(DESTDIR)$(INSTALL_DATADIR)/resources" \
            install-data-recursive
	$(INSTALL_DATA) "COPYING.txt" "$(DESTDIR)$(INSTALL_DATADIR)/COPYING.txt"

.PHONY: install-data-recursive
install-data-recursive:
# Note: the project contains filesnames with whitespace 
	$(MKDIR) "$(RECURSIVE_DST_DIR)"
	@for file in "$(RECURSIVE_SRC_DIR)"/*; do \
	  if test -f "$${file}"; then \
	    filename=`basename "$${file}"`; \
	    echo "$(INSTALL_DATA) \"$${file}\" \"$(RECURSIVE_DST_DIR)/$${filename}\""; \
	    $(INSTALL_DATA) "$${file}" "$(RECURSIVE_DST_DIR)/$${filename}" || exit 1; \
	  fi; \
	  if test -d "$${file}"; then \
	    subdir="$${file}"; \
	    subdirname=`basename "$${subdir}"`; \
	    $(MAKE) RECURSIVE_SRC_DIR="$${subdir}" \
	            RECURSIVE_DST_DIR="$(RECURSIVE_DST_DIR)/$${subdirname}" \
	            install-data-recursive || exit 1; \
	  fi; \
	done

.PHONY: uninstall-local
uninstall-local: uninstall-all

.PHONY: uninstall-all
uninstall-all: uninstall-data uninstall-exec uninstall-plugins

.PHONY: uninstall-data
uninstall-data:
	$(RM_REC) "$(DESTDIR)$(INSTALL_DATADIR)/languages"
	$(RM_REC) "$(DESTDIR)$(INSTALL_DATADIR)/sounds"
	$(RM_REC) "$(DESTDIR)$(INSTALL_DATADIR)/themes"
	$(RM_REC) "$(DESTDIR)$(INSTALL_DATADIR)/fonts"
	$(RM_REC) "$(DESTDIR)$(INSTALL_DATADIR)/resources"
	$(RM)     "$(DESTDIR)$(INSTALL_DATADIR)/COPYING.txt"
	-rmdir "$(DESTDIR)$(INSTALL_DATADIR)"

.PHONY: uninstall-exec
uninstall-exec:
	$(RM) "$(DESTDIR)$(bindir)/$(USDX_BIN_NAME)"

.PHONY: uninstall-plugins
uninstall-plugins:
	$(RM_REC) "$(DESTDIR)$(INSTALL_DATADIR)/plugins"

#################################################
# Distributable source-package (TODO)
#################################################

disttmpdir := $(USDX_PACKAGE_NAME)-1.1_alpha-src

.PHONY: dist-local
dist-local:
	@$(svn-files) | while read FILE; do \
	  if test -d "$${FILE}"; then \
	    echo "MKDIR: $(disttmpdir)/$${FILE}"; \
	    $(MKDIR) "$(disttmpdir)/$${FILE}" || exit 1; \
	  else \
	    echo "COPY:  $${FILE}"; \
	    cp "$${FILE}" "$(disttmpdir)/$${FILE}" || exit 1; \
	  fi; \
	done
	tar cvf $(disttmpdir).tar $(disttmpdir)
	gzip $(disttmpdir).tar
	$(RM_REC) $(disttmpdir) || rmdir $(disttmpdir)

#################################################
# Debian package
#################################################

debpkgdir    ?= dists/debian
debpkgtmpdir := $(debpkgdir)/deb-package
debpkgprefix := $(USDX_PACKAGE_NAME)
debpkgname   := $(debpkgprefix)_$(USDX_VERSION)_$(PPROCESSOR).deb

.PHONY: deb
deb: all
	$(RM_REC) $(debpkgtmpdir) || rmdir $(debpkgtmpdir)
	$(MKDIR) $(debpkgdir)
	$(MKDIR) $(debpkgtmpdir)/DEBIAN
	$(MAKE) DESTDIR=$(debpkgtmpdir)/ install-all
	$(INSTALL_DATA) $(debpkgdir)/$(debpkgprefix).control $(debpkgtmpdir)/DEBIAN/control
	dpkg-deb --build $(debpkgtmpdir)
	mv $(debpkgtmpdir)/../deb-package.deb $(debpkgdir)/$(debpkgname)
	$(RM_REC) $(debpkgtmpdir) || rmdir $(debpkgtmpdir)

#################################################
# RPM (TODO)
#################################################

.PHONY: rpm
rpm: all
	@echo "$@: Coming soon"


#################################################
# Mac OS X defines
#################################################

# otool: Mac OS X object file displaying tool
OTOOL := @OTOOL@ 
# install_name_tool: Mac OS X tool to change dynamic shared library install names
INSTALL_NAME_TOOL := @INSTALL_NAME_TOOL@
# hdiutil: Mac OS X disk image tool
HDIUTIL := @HDIUTIL@

#################################################
# Mac OS X app-bundle
#################################################

macosx_bundle_path := UltraStarDeluxe.app/Contents
.PHONY: macosx-app
macosx-app: all 
# Create double clickable Mac OS X application.
	@echo ""
	@echo "Creating the Mac OS X application"
	@echo ""
	$(MKDIR) $(macosx_bundle_path)
# Put the icon file into its particular place. 
# Must be done BEFORE info.plist is created.
	$(MKDIR) $(macosx_bundle_path)/resources
	$(INSTALL_DATA) icons/ultrastardx.icns $(macosx_bundle_path)/resources/
# the info.plist file:
	$(INSTALL_DATA) $(USDX_SRC_DIR)/macosx/Info.plist $(macosx_bundle_path)/
# Copy the resources. 
	$(MAKE) install-all INSTALL_DATADIR=$(macosx_bundle_path) bindir=$(macosx_bundle_path)/MacOS
# Copy the lua plugins. 
	$(MAKE) install-plugins INSTALL_DATADIR=$(macosx_bundle_path) bindir=$(macosx_bundle_path)/MacOS
# Create the song directory. 
	$(MKDIR) $(macosx_bundle_path)/songs
# final messages
	@echo ""
	@echo "Mac OS X application created."
	@echo "Please report issues to the developer team, preferably mischi."
	@echo "Have fun."
	@echo ""

.PHONY: macosx-standalone-app
macosx-standalone-app: macosx-app 
# Create double clickable standalone (does not need fink) Mac OS X 
# application. Not fully test, but should work on 10.5.
	@echo ""
	@echo "Creating the standalone Mac OS X application"
	@echo ""
# copy the dylib and change its install names:

define install_osx_libraries
    $(shell $(INSTALL) -m 755 $(dylib) $(macosx_bundle_path)/MacOS)
    $(shell $(INSTALL_NAME_TOOL) -change $(dylib) @executable_path/$(notdir $(dylib)) $(macosx_bundle_path)/MacOS/ultrastardx)
    $(shell $(INSTALL_NAME_TOOL) -id @executable_path/$(notdir $(dylib)) $(macosx_bundle_path)/MacOS/$(notdir $(dylib)))
    $(foreach linked_dylibs_2,$(shell $(OTOOL) -L $(dylib) | grep version | cut -f 1 -d ' ' | grep -v \/System\/Library | grep -v \usr\/lib | grep -v executable_path),$(rename_secondary_osx_libraries))
endef

define rename_secondary_osx_libraries
    $(shell $(INSTALL_NAME_TOOL) -change $(linked_dylibs_2) @executable_path/$(notdir $(linked_dylibs_2)) $(macosx_bundle_path)/MacOS/$(notdir $(dylib)))
endef

# work on the dylibs in $(macosx_bundle_path)/MacOS/ultrastardx
	$(foreach dylib,$(shell $(OTOOL) -L $(macosx_bundle_path)/MacOS/ultrastardx | grep version | cut -f 1 -d ' ' | grep -v \/System\/Library | grep -v \/usr\/lib),$(install_osx_libraries))

# work on the secondary dylibs from ffmpeg
# libavcodec references all tertiary libraries of the ffmpeg libs
	$(foreach dylib,$(shell $(OTOOL) -L /sw/lib/libavcodec.dylib   | grep version | cut -f 1 -d ' ' | grep -v \/System\/Library | grep -v \/usr\/lib),$(install_osx_libraries))
# same procedure in libfaac. it gets libgnugetopt
	$(foreach dylib,$(shell $(OTOOL) -L /sw/lib/libfaac.dylib      | grep version | cut -f 1 -d ' ' | grep -v \/System\/Library | grep -v \/usr\/lib),$(install_osx_libraries))

# same procedure for tertiary libs in SDL_image
	$(foreach dylib,$(shell $(OTOOL) -L /sw/lib/libSDL_image.dylib | grep version | cut -f 1 -d ' ' | grep -v \/System\/Library | grep -v \/usr\/lib),$(install_osx_libraries))

# X11 libs as well, because users may not have installed it on 10.4
	$(foreach dylib,$(shell $(OTOOL) -L /usr/X11R6/lib/libX11.dylib  | grep version | cut -f 1 -d ' ' | grep -v \/System\/Library | grep -v \/usr\/lib),$(install_osx_libraries))

# final messages
	@echo "Standalone Mac OS X application created."
	@echo ""

.PHONY: macosx-dmg
macosx-dmg: macosx-standalone-app
	$(RM) UltraStarDeluxe.dmg
	$(RM) UltraStarDeluxe.sparseimage
	$(HDIUTIL) create -type SPARSE -size 100m -fs HFS+ -volname UltraStarDeluxe -ov UltraStarDeluxe.sparseimage
	$(HDIUTIL) attach UltraStarDeluxe.sparseimage
	/bin/cp -R UltraStarDeluxe.app /Volumes/UltraStarDeluxe
	$(HDIUTIL) detach /Volumes/UltraStarDeluxe
	$(HDIUTIL) convert UltraStarDeluxe.sparseimage -format UDBZ -o UltraStarDeluxe.dmg
	$(RM) UltraStarDeluxe.sparseimage

# remove Mac OS X apllication bundle and disk image
.PHONY: clean-macosx
clean-macosx: clean-macosx-app clean-macosx-dmg

.PHONY: clean-macosx-app
clean-macosx-app:
	$(RM_REC) UltraStarDeluxe.app || rmdir UltraStarDeluxe.app

.PHONY: clean-macosx-dmg
clean-macosx-dmg:
	$(RM) UltraStarDeluxe.dmg 
	$(RM) UltraStarDeluxe.sparseimage
