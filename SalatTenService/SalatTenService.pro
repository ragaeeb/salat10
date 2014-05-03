APP_NAME = SalatTenService

INCLUDEPATH += ../src ../../../canadainc/src/ ../../salat/src/
CONFIG += qt warn_on
LIBS += -lbb -lbbsystem -lbbplatform -lbbmultimedia -lbbnetwork

CONFIG(release, debug|release) {
    DESTDIR = o.le-v7
    LIBS += -L../../../canadainc/arm/o.le-v7 -lcanadainc -Bdynamic
    LIBS += -L../../salat/arm/o.le-v7 -lsalat -Bdynamic
}

CONFIG(debug, debug|release) {
    DESTDIR = o.le-v7-g
    LIBS += -L../../../canadainc/arm/o.le-v7-g -lcanadainc -Bdynamic
    LIBS += -L../../salat/arm/o.le-v7-g -lsalat -Bdynamic
}

simulator {
CONFIG(release, debug|release) {
    DESTDIR = o
    LIBS += -Bstatic -L../../../canadainc/x86/o-g/ -lcanadainc -Bdynamic
    LIBS += -Bstatic -L../../salat/x86/o-g/ -lsalat -Bdynamic     
}
CONFIG(debug, debug|release) {
    DESTDIR = o-g
    LIBS += -Bstatic -L../../../canadainc/x86/o-g/ -lcanadainc -Bdynamic
    LIBS += -Bstatic -L../../salat/x86/o-g/ -lsalat -Bdynamic
}
}

include(config.pri)