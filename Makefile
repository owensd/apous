TEMPORARY_FOLDER=/tmp/Apous.dst
PREFIX=/usr/local
BUILD_TOOL=xcodebuild

XCODEFLAGS=-project 'apous.xcodeproj' -scheme 'apous' DSTROOT=$(TEMPORARY_FOLDER)

APOUS_EXECUTABLE=$(TEMPORARY_FOLDER)/apous

FRAMEWORKS_FOLDER=/Library/Frameworks
BINARIES_FOLDER=/usr/local/bin

VERSION_STRING=v0.2.0
COMPONENTS_PLIST=misc/Components.plist

OUTPUT_PACKAGE=Apous.pkg

.PHONY: all bootstrap clean install package test uninstall

all: bootstrap
	$(BUILD_TOOL) $(XCODEFLAGS) build

bootstrap:
	misc/scripts/bootstrap.sh

test: clean bootstrap
	$(BUILD_TOOL) $(XCODEFLAGS) test

clean:
	rm -f "$(OUTPUT_PACKAGE)"
	rm -rf "$(TEMPORARY_FOLDER)"
	$(BUILD_TOOL) $(XCODEFLAGS) clean

install: package
	sudo installer -pkg "$(TEMPORARY_FOLDER)/$(OUTPUT_PACKAGE)" -target /

uninstall:
	rm -f "$(BINARIES_FOLDER)/apous"

installables: clean bootstrap
	$(BUILD_TOOL) $(XCODEFLAGS) install

	mkdir -p "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)"

prefix_install: installables
	mkdir -p "$(PREFIX)/Frameworks" "$(PREFIX)/bin"
	cp -f "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)/apous" "$(PREFIX)/bin/"

package: installables
	pkgbuild \
		--component-plist "$(COMPONENTS_PLIST)" \
		--identifier "io.owensd.apous" \
		--install-location "/" \
		--root "$(TEMPORARY_FOLDER)" \
		--version "$(VERSION_STRING)" \
		"$(TEMPORARY_FOLDER)/$(OUTPUT_PACKAGE)"