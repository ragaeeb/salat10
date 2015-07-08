#include "precompiled.h"

#include "Offloader.h"
#include "AccountImporter.h"
#include "CleanupEvents.h"
#include "IOUtils.h"
#include "Logger.h"
#include "SalatUtils.h"
#include "ScheduleEvents.h"
#include "ThreadUtils.h"

namespace salat {

using namespace bb::cascades::maps;
using namespace bb::platform::geo;
using namespace canadainc;

Offloader::Offloader() :
        m_cleanup(NULL), m_schedule(NULL), m_timeRender(bb::system::LocaleType::Region)
{
    connect( &m_qfw, SIGNAL( finished() ), this, SLOT( onBlurred() ) );
}


void Offloader::blur(bb::cascades::ImageView* i, QString const& imageSrc)
{
    if ( m_blurred.isNull() )
    {
        QFuture< QPair<bb::ImageData, bb::cascades::ImageView*> > future = QtConcurrent::run(&ThreadUtils::applyBlur, i, imageSrc);
        m_qfw.setFuture(future);
    } else {
        i->setImage(m_blurred);
    }
}


void Offloader::onBlurred()
{
    QPair<bb::ImageData, bb::cascades::ImageView*> blurredPic = m_qfw.result();

    m_blurred = bb::cascades::Image(blurredPic.first);
    blurredPic.second->setImage(m_blurred);
}


bool Offloader::hasCalendarAccess()
{
    bb::pim::calendar::CalendarSettings cs = bb::pim::calendar::CalendarService().settings();
    bool ok = cs.isValid();

    if (!ok) {
        //m_persistance.showBlockingToast( tr("Warning: It seems like the app does not have access to your Calendar. This permission is needed for the app to respond to 'calendar' commands if you want to ever check your device's local calendar remotely. If you leave this permission off, some features may not work properly. Tap OK to enable the permissions in the Application Permissions page."), tr("OK"), "asset:///images/toast/ic_calendar_empty.png" );
        //InvocationUtils::launchAppPermissionSettings();
    }

    return ok;
}


void Offloader::loadAccounts()
{
    AccountImporter* ai = new AccountImporter(Service::Calendars);
    connect( ai, SIGNAL( importCompleted(QVariantList const&) ), this, SIGNAL( accountsImported(QVariantList const&) ) );
    IOUtils::startThread(ai);
}


void Offloader::renderMap(MapView* mapControl, qreal latitude, qreal longitude, QString const& name, QString const& event, bool focus)
{
    GeoLocation* home = new GeoLocation(latitude, longitude);
    home->setName(name);
    home->setDescription(event);
    mapControl->mapData()->add(home);

    if (focus)
    {
        mapControl->setFocusedId( home->id() );
        mapControl->setLocationOnFocused();
    }
}


void Offloader::exportToCalendar(int numDays, QVariantList const& toExport, qint64 accountId)
{
    LOGGER(numDays << toExport << accountId);

    QMap<QString, int> events;

    for (int i = toExport.size()-1; i >= 0; i--)
    {
        QVariantMap current = toExport[i].toMap();
        events[ current.value(PRAYER_KEY).toString() ] = current.value(PRAYER_TIME_VALUE).toInt();
    }

    terminateThreads();

    m_schedule = new ScheduleEvents(numDays, events, accountId);
    connect( m_schedule, SIGNAL( progress(int, int) ), this, SIGNAL( operationProgress(int, int) ) );
    connect( m_schedule, SIGNAL( destroyed(QObject*) ), this, SLOT( handleExportComplete(QObject*) ) );

    IOUtils::startThread(m_schedule);
}


void Offloader::cleanupCalendarEvents()
{
    LOGGER("cleanupCalendarEvents");

    terminateThreads();

    m_cleanup = new CleanupEvents();
    connect( m_cleanup, SIGNAL( progress(int, int) ), this, SIGNAL( operationProgress(int, int) ) );
    connect( m_cleanup, SIGNAL( destroyed(QObject*) ), this, SLOT( handleCleanupComplete(QObject*) ) );

    IOUtils::startThread(m_cleanup);
}


void Offloader::handleCleanupComplete(QObject* obj)
{
    LOGGER("handleCleanupComplete");

    Q_UNUSED(obj);
    emit operationComplete( tr("Scheduled events cleared!"), "asset:///images/menu/ic_calendar_delete.png" );
}


void Offloader::handleExportComplete(QObject* obj)
{
    LOGGER("handleExportComplete");

    Q_UNUSED(obj);
    emit operationComplete( tr("Export complete!"), "file:///usr/share/icons/ic_add_event.png" );
}


void Offloader::terminateThreads()
{
    if (m_cleanup) {
        m_cleanup->cancel();
    }

    if (m_schedule) {
        m_schedule->cancel();
    }
}


QString Offloader::renderStandardTime(QDateTime const& theTime)
{
    static QString format = bb::utility::i18n::timeFormat(bb::utility::i18n::DateFormat::Short);
    return m_timeRender.locale().toString(theTime, format);
}


Offloader::~Offloader()
{
}

} /* namespace quran */
