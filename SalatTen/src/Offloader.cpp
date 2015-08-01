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
    return cs.isValid();
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


bool Offloader::isServiceRunning()
{
    return QFile::exists(ACTIVE_SERVICE_FILE);
}


QString Offloader::renderStandardTime(QDateTime const& theTime)
{
    static QString format = bb::utility::i18n::timeFormat(bb::utility::i18n::DateFormat::Short);
    return m_timeRender.locale().toString(theTime, format);
}


void Offloader::renderSalaf(bb::cascades::maps::MapView* mapControl, QVariantMap const& data)
{
    GeoLocation* home = new GeoLocation( data.value("latitude").toReal(), data.value("longitude").toReal() );
    home->setName( data.value("name").toString() );
    home->setDescription( data.value("city").toString() );
    home->setGeoId( QString::number( data.value("id").toLongLong() ) );
    Marker m = home->marker();
    m.setIconUri( data.value("is_companion").toInt() == 1 ? "asset:///images/ic_map_companion.png" : "asset:///images/ic_map_rijaal.png");
    home->setMarker(m);
    mapControl->mapData()->add(home);
}


Offloader::~Offloader()
{
}

} /* namespace quran */
