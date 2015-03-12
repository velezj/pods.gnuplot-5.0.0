# pod Makefile created using pods-tools/create-configure-pod.sh

FETCH_URL=http://downloads.sourceforge.net/project/gnuplot/gnuplot/5.0.0/gnuplot-5.0.0.tar.gz
POD_NAME=gnuplot-5.0.0

default_target: all

# Default to a less-verbose build.  If you want all the gory compiler output,
# run "make VERBOSE=1"
$(VERBOSE).SILENT:

# Figure out where to build the software.
#   Use BUILD_PREFIX if it was passed in.
#   If not, search up to four parent directories for a 'build' directory.
#   Otherwise, use ./build.
ifeq "$(BUILD_PREFIX)" ""
BUILD_PREFIX:=$(shell for pfx in ./ .. ../.. ../../.. ../../../..; do d=`pwd`/$$pfx/build;\
               if [ -d $$d ]; then echo $$d; exit 0; fi; done; echo `pwd`/build)
endif
# create the build directory if needed, and normalize its path name
BUILD_PREFIX:=$(shell mkdir -p $(BUILD_PREFIX) && cd $(BUILD_PREFIX) && echo `pwd`)

# Default to a release build.  If you want to enable debugging flags, run
# "make BUILD_TYPE=Debug"
ifeq "$(BUILD_TYPE)" ""
BUILD_TYPE="Release"
endif

all: pkgconfiged.touch
	@echo "\nBUILD_PREFIX: $(BUILD_PREFIX)\n\n"

fetched.touch:
	$(MAKE) fetch

unarchived.touch: fetched.touch
	$(MAKE) unarchive

built.touch: unarchived.touch
	$(MAKE) build-source

installed.touch: built.touch
	$(MAKE) install-source

pkgconfiged.touch: installed.touch
	$(MAKE) pkgconfig-source

fetch:
	@echo "\n Fetching $(POD_NAME) from $(FETCH_URL) \n"
	wget -O $(POD_NAME).tar.gz $(FETCH_URL)
	@touch fetched.touch

unarchive:
	@echo "\n UnArchiving $(POD_NAME) \n"
	@tar xzf $(POD_NAME).tar.gz
	@touch unarchived.touch

build-source:
	@echo "\n Building $(POD_NAME) \n"
	@mkdir -p pod-build
	cd pod-build && ../$(POD_NAME)/configure --prefix=$(BUILD_PREFIX)
	cd pod-build && make
	@touch built.touch

install-source:
	@echo "\n Installing $(POD_NAME) \n"
	cd pod-build && make install
	@touch installed.touch

pkgconfig-source:
	@echo "\n Creating pkg-config files for $(POD_NAME) \n"
	@touch pkgconfiged.touch



clean:
	-if [ -e pod-build/install_manifest.txt ]; then rm -f `cat pod-build/install_manifest.txt`; fi
	-if [ -d pod-build ]; then $(MAKE) -C pod-build clean; rm -rf pod-build; fi
	rm -rf $(POD_NAME)
	rm -f unarchived.touch built.touch installed.touch pkgconfiged.touch

# other (custom) targets are passed through to the cmake-generated Makefile 
%::
	$(MAKE) -C pod-build $@
