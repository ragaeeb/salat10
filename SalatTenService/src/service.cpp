#include "precompiled.h"

#include "service.hpp"
#include "Logger.h"
#include "LogMonitor.h"
#include "IOUtils.h"
#include "SalatUtils.h"
#include "Translator.h"

#define audio_fajr_athaan "asset:///audio/athaan_fajr.mp3"
#define audio_athaan "asset:///audio/athan_albaani.mp3"
#define BLACKBERRY_PUSH_APPLICATION_ID "1171-9014r27221trt37r2o430150l5a1es42l44"
#define BLACKBERRY_PUSH_URL "https://cp1171.pushapi.na.blackberry.com"

namespace {

QList<QDateTime> adjust(QList<QDateTime> list, QStringList const& allEvents, QVariantMap const& adjustments)
{
    for (int i = list.size()-1; i >= 0; i--) {
        int adjust = adjustments.value( allEvents[i] ).toInt();
        list[i] = list[i].addSecs(adjust*60);
    }

    return list;
}

}

namespace salat {

using namespace bb::network;
using namespace bb::system;
using namespace bb::platform;
using namespace bb::multimedia;
using namespace canadainc;

Service::Service(bb::Application* app) :
            QObject(app), m_pushService(BLACKBERRY_PUSH_APPLICATION_ID, "com.canadainc.SalatTenService", app)
{
    m_athan.mkw = NULL;
    m_athan.skipJumuah = true;
    m_athan.atLeastOneEvent = true;

    if ( !QFile::exists( m_settings.fileName() ) )
    {
        m_settings.setValue( "init", QDateTime::currentMSecsSinceEpoch() );
        m_settings.sync();
    }

    m_settingsWatcher.addPath( m_settings.fileName() );

    connect( this, SIGNAL( initialize() ), this, SLOT( init() ), Qt::QueuedConnection ); // async startup
    emit initialize();
}


void Service::init()
{
    LogMonitor::create(SERVICE_KEY, SERVICE_LOG_FILE, this);

    m_athan.timer.setSingleShot(true);
    connect( &m_athan.timer, SIGNAL( timeout() ), this, SLOT( timeout() ) );
    connect( &m_settingsWatcher, SIGNAL( fileChanged(QString const&) ), this, SLOT( recalculate(QString const&) ) );
    connect( &m_clock, SIGNAL( clockSettingsChanged() ), this, SLOT( recalculate() ) );
    connect( &m_invokeManager, SIGNAL( invoked(const bb::system::InvokeRequest&) ), this, SLOT( handleInvoke(const bb::system::InvokeRequest&) ) );
    connect( &m_athan.player, SIGNAL( playbackCompleted() ), this, SLOT( onPlayingStateChanged() ) );
    connect( &m_athan.player, SIGNAL( playingChanged() ), this, SLOT( onPlayingStateChanged() ) );

    connect( &m_pushService, SIGNAL( createSessionCompleted(bb::network::PushStatus const&) ), SLOT( createSessionCompleted(bb::network::PushStatus const&) ) );

    m_pushService.createSession();

    recalculate();
}


void Service::createChannelCompleted(bb::network::PushStatus const& status, QString const& token)
{
    LOGGER( status.isError() << token );
    m_pushService.registerToLaunch();
}


void Service::createSessionCompleted(const bb::network::PushStatus& status)
{
    LOGGER( status.isError() );

    if ( !status.isError() ) {
        connect( &m_pushService, SIGNAL( createChannelCompleted(bb::network::PushStatus const&, QString const&) ), SLOT( createChannelCompleted(bb::network::PushStatus const&, QString const&) ) );
        m_pushService.createChannel( QUrl(BLACKBERRY_PUSH_URL) );
    }
}


void Service::onPlayingStateChanged()
{
    if ( !m_athan.player.playing() && m_athan.mkw )
    {
        LOGGER("No longer playing, destroying!");
        m_athan.mkw->deleteLater();
        m_athan.mkw = NULL;
    }
}


void Service::timeout(bool init)
{
    QDateTime now = QDateTime::currentDateTime();
    LOGGER(init << now);

    m_params.geo = Calculator::createCoordinates( now, m_settings.value("latitude"), m_settings.value("longitude") );
    QStringList allEvents = Translator::eventKeys();

    Calculator calculator;
    QList<QDateTime> result = adjust( calculator.calculate( now.date().addDays(-1), m_params.geo, m_params.angles, m_params.asrRatio ), allEvents, m_params.adjustments );
    result.append( adjust( calculator.calculate( now.date(), m_params.geo, m_params.angles, m_params.asrRatio ), allEvents, m_params.adjustments ) );
    result.append( adjust( calculator.calculate( now.date().addDays(1), m_params.geo, m_params.angles, m_params.asrRatio ), allEvents, m_params.adjustments ) );

    allEvents.append( Translator::eventKeys() );
    allEvents.append( Translator::eventKeys() );

    QString currentEventKey;
    QDateTime currentEventTime;
    QDateTime nextEventTime;

    for (int i = 0; i < result.size(); i++)
    {
        if ( now < result[i] ) {
            currentEventKey = allEvents[i-1];
            currentEventTime = result[i-1];
            nextEventTime = result[i];
            break;
        }
    }

    LOGGER("Current" << currentEventKey << currentEventTime << now << nextEventTime);

    qint64 diff = nextEventTime.toMSecsSinceEpoch() - now.toMSecsSinceEpoch() + 1000; // 1 second lee way in case the OS pre-empts us too early
    m_athan.timer.start(diff);

    LOGGER("Started timer for " << diff);

    if (!init)
    {
        bool playAthaan = m_athan.athaans.value(currentEventKey).toBool();
        bool playNotification = m_athan.notifications.value(currentEventKey).toBool();
        Translator t;
        QMap<QString, bool> salatMap = t.salatMap();

        LOGGER("Athaans" << m_athan.athaans << playAthaan << m_athan.notifications << playNotification);

        if ( playAthaan && (m_athan.prevKey != currentEventKey) && salatMap.contains(currentEventKey) )
        {
            if ( currentEventKey == Translator::key_dhuhr && now.date().dayOfWeek() == Qt::Friday && m_athan.skipJumuah ) {
                LOGGER("Skipping athaan because it is Friday and user chose not to play it on Ju'muah.");
            } else {
                NotificationGlobalSettings g;
                NotificationMode::Type mode = g.mode();
                bool okToPlay = m_athan.profiles.value( QString::number(mode) ).toBool();

                LOGGER("okToPlay" << okToPlay);

                if (okToPlay)
                {
                    LOGGER("Playing athaan mode" << mode);
                    QString destinationFile = currentEventKey == Translator::key_fajr ? audio_fajr_athaan : audio_athaan;

                    QString customFile = m_athan.customAthaans.value(currentEventKey).toString();

                    LOGGER("Custom file" << customFile);

                    if ( customFile.startsWith("asset://") || QFile::exists( QUrl(customFile).toLocalFile() ) ) {
                        destinationFile = customFile;
                    }

                    m_athan.prevKey = currentEventKey;
                    LOGGER( "Playing with volume" << m_athan.player.volume() );
                    m_athan.player.play(destinationFile);

                    if (m_athan.mkw == NULL) {
                        m_athan.mkw = new MediaKeyWatcher(MediaKey::VolumeDown, this);
                        connect( m_athan.mkw, SIGNAL( shortPress(bb::multimedia::MediaKey::Type) ), this, SLOT( onShortPress(bb::multimedia::MediaKey::Type) ) );
                    }
                } else {
                    LOGGER("Skipping athaan mode" << mode);
                }
            }
        } else if (playNotification) {
            Notification n;
            n.setTitle("Salat10");
            n.setBody( t.render(currentEventKey) );
            n.setTimestamp(currentEventTime);
            n.setIconUrl( QString("file:///usr/share/icons/clock_alarm.png") );
            n.notify();
        }
    }
}


void Service::onShortPress(bb::multimedia::MediaKey::Type key)
{
    LOGGER("SHORT PRESSED!!!!" << key << m_athan.player.playing());

    if ( m_athan.player.playing() && key == MediaKey::VolumeDown )
    {
        LOGGER("STOPPING");
        m_athan.player.stop();
        Notification::clearEffectsForAll();
        Notification::deleteAllFromInbox();
    }
}


void Service::recalculate(QString const& path)
{
    Q_UNUSED(path);

    m_settings.sync();

    if ( m_settings.contains("latitude") && m_settings.contains("longitude") && m_settings.contains("angles") )
    {
        m_params.angles = Calculator::createParams( m_settings.value("angles").toMap() );
        m_params.asrRatio = m_settings.value("asrRatio").toReal();
        m_params.adjustments = m_settings.value("adjustments").toMap();

        m_athan.athaans = m_settings.value("athaans").toMap();
        m_athan.notifications = m_settings.value("notifications").toMap();
        m_athan.profiles = m_settings.value("profiles").toMap();
        m_athan.customAthaans = m_settings.value("customAthaans").toMap();
        m_athan.skipJumuah = m_settings.value("skipJumahAthaan").toInt() == 1;
        LOGGER("new vol received" << m_settings.value("athanVolume").toDouble());
        m_athan.player.setVolume( m_settings.contains("athanVolume") ? m_settings.value("athanVolume").toDouble() : 1 );
        LOGGER("new vol" << m_athan.player.volume());

        QVariantList values = m_athan.athaans.values();
        values.append( m_athan.notifications.values() );

        m_athan.atLeastOneEvent = values.contains(true);
        m_athan.prevKey = QString();

        if (m_athan.atLeastOneEvent) { // if there exists at least one notification or athan, then let's do it
            timeout(true);
        } else {
            m_athan.timer.stop();
            LOGGER("User chose not to have any athans or notifications");
        }
    }
}


void Service::create(bb::Application* app) {
    new Service(app);
}


void Service::handleInvoke(bb::system::InvokeRequest const& request)
{
    QString action = request.action();
    LOGGER("handleInvoke!" << action);

    if ( action.compare("com.canadainc.SalatTenService.RESET") == 0 && m_athan.atLeastOneEvent && !m_athan.timer.isActive() ) {
        recalculate();
    } else if ( action.compare("bb.action.PUSH") == 0 ) {
        PushPayload payload(request);

        if ( payload.isValid() )
        {
            QStringList tokens = QString( payload.data() ).split("|");
            LOGGER(tokens);

            if ( !tokens.isEmpty() )
            {
                Notification n;
                n.setTitle("Salat10");
                n.setBody( tokens.first() );

                QDateTime timestamp = tokens.size() > 1 ? QDateTime::fromMSecsSinceEpoch( tokens[1].toLongLong() ) : QDateTime::currentDateTime();
                n.setTimestamp(timestamp);

                n.setIconUrl( QString("file:///usr/share/icons/ic_go.png") );
                LOGGER("Valid push data received, notifying");
                n.notify();
            } else {
                LOGGER("Corrupt push data received!");
            }
        }
    }
}


Service::~Service()
{
}

} // salat
