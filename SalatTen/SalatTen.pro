APP_NAME = Salat10

INCLUDEPATH += ../src ../../../canadainc/src/ ../../salat/src/
CONFIG += qt warn_on cascades10 mobility
LIBS += -lbbplatform -lbbplatformplaces -lbbcascadesmaps -lbbcascadesplaces -lbbsystem -lbbdevice
LIBS += -lbbpim -lbb -lbbutilityi18n -lQtLocationSubset -lbbdata -lbbcascadespickers
INCLUDEPATH += ../../../quazip/src/
MOBILITY += sensors
QT += network

CONFIG(release, debug|release) {
    DESTDIR = o.le-v7
    LIBS += -L../../../canadainc/arm/o.le-v7 -lcanadainc -Bdynamic
    LIBS += -L../../salat/arm/o.le-v7 -lsalat -Bdynamic
    LIBS += -Bstatic -L../../../quazip/arm/o.le-v7 -lquazip -Bdynamic
    LIBS += -Bstatic -L../../../quazip/arm/o.le-v7 -lquazip -Bdynamic
}

CONFIG(debug, debug|release) {
    DESTDIR = o.le-v7-g
    LIBS += -L../../../canadainc/arm/o.le-v7-g -lcanadainc -Bdynamic
    LIBS += -L../../salat/arm/o.le-v7-g -lsalat -Bdynamic
    LIBS += -Bstatic -L../../../quazip/arm/o.le-v7-g -lquazip -Bdynamic
}

simulator {

CONFIG(debug, debug|release) {
    DESTDIR = o-g
    LIBS += -Bstatic -L../../../canadainc/x86/o-g/ -lcanadainc -Bdynamic
    LIBS += -Bstatic -L../../salat/x86/o-g/ -lsalat -Bdynamic
}

}

include(config.pri)