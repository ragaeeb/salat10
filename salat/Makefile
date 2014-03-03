QMAKE_TARGET  = salat
QMAKE         = $(QNX_HOST)/usr/bin/qmake
TARGET        = $(QMAKE_TARGET)


all: Makefile $(QMAKE_TARGET)

clean: FORCE
	$(MAKE) -C ./arm -f Makefile sureclean	
	$(MAKE) -C ./x86 -f Makefile sureclean
	rm -rf arm arm-p x86
	rm -f $(I18N_DIR)/*.qm

Makefile: FORCE	
	$(QMAKE) -spec unsupported/blackberry-armv7le-qcc -o arm/Makefile $(QMAKE_TARGET).pro CONFIG+=device
	$(QMAKE) -spec unsupported/blackberry-x86-qcc -o x86/Makefile $(QMAKE_TARGET).pro CONFIG+=simulator
	$(MAKE) -C ./translations -f Makefile update release

FORCE:

$(QMAKE_TARGET): device simulator

device:
	$(MAKE) -C ./arm -f Makefile all

Device-Debug: Makefile
	$(MAKE) -C ./arm -f Makefile debug
	
Device-Release: Makefile
	$(MAKE) -C ./arm -f Makefile release

simulator:
	$(MAKE) -C ./x86 -f Makefile all

Simulator-Debug: Makefile
	$(MAKE) -C ./x86 -f Makefile debug