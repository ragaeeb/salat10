#include "precompiled.h"

#include "service.hpp"
#include "Logger.h"
#include "IOUtils.h"
#include "SalatUtils.h"
#include "Translator.h"

#define audio_fajr_athaan "asset:///audio/athaan_fajr.mp3"
#define audio_athaan "asset:///audio/athan_albaani.mp3"

namespace {

QList<QDateTime> adjust(QList<QDateTime> list, QStringList const& allEvents, QVariantMap const& adjustments, int dstAdjust)
{
    for (int i = list.size()-1; i >= 0; i--) {
        int adjust = adjustments.value( allEvents[i] ).toInt();
        list[i] = list[i].addSecs(adjust*60).addSecs(dstAdjust*3600);
    }

    return list;
}

}

namespace salat {

using namespace bb::system;
using namespace bb::platform;
using namespace bb::multimedia;
using namespace canadainc;

Service::Service(bb::Application* app) : QObject(app)
{
    IOUtils::writeFile(ACTIVE_SERVICE_FILE, QByteArray(), false);

    m_athan.mkw = NULL;
    m_athan.skipJumuah = true;
    m_athan.atLeastOneEvent = true;

    if ( !QFile::exists( m_settings.fileName() ) )
    {
        m_settings.setValue(KEY_CALC_STRATEGY, KEY_CALC_STRATEGY_ISNA);
        m_settings.sync();
    }

    m_settingsWatcher.addPath( m_settings.fileName() );

    connect( this, SIGNAL( initialize() ), this, SLOT( init() ), Qt::QueuedConnection ); // async startup
    emit initialize();
}


void Service::init()
{
    m_athan.timer.setSingleShot(true);
    connect( &m_athan.timer, SIGNAL( timeout() ), this, SLOT( timeout() ) );
    connect( &m_settingsWatcher, SIGNAL( fileChanged(QString const&) ), this, SLOT( recalculate(QString const&) ) );
    connect( &m_clock, SIGNAL( clockSettingsChanged() ), this, SLOT( recalculate() ) );
    connect( &m_invokeManager, SIGNAL( invoked(const bb::system::InvokeRequest&) ), this, SLOT( handleInvoke(const bb::system::InvokeRequest&) ) );
    connect( &m_athan.player, SIGNAL( playbackCompleted() ), this, SLOT( onAthanStateChanged() ) );
    connect( &m_athan.player, SIGNAL( playingChanged() ), this, SLOT( onAthanStateChanged() ) );
    connect( &m_athan.player, SIGNAL( error(QString const&) ), this, SLOT( error(QString const&) ) );

    recalculate();
}


void Service::error(QString const& message)
{
    LOGGER(message);

    if (m_athan.mkw)
    {
        m_athan.mkw->deleteLater();
        m_athan.mkw = NULL;
    }
}


void Service::onAthanStateChanged()
{
    MediaPlayer* mp = m_athan.player.mediaPlayer();

    if ( mp && mp->mediaState() == MediaState::Stopped && m_athan.mkw )
    {
        LOGGER("AthanDestroyed!");
        m_athan.mkw->deleteLater();
        m_athan.mkw = NULL;
    }
}


void Service::timeout(bool init)
{
    QDateTime now = QDateTime::currentDateTime();

    m_params.geo = Calculator::createCoordinates( now, m_settings.value(KEY_CALC_LATITUDE).toReal(), m_settings.value(KEY_CALC_LONGITUDE).toReal() );
    QStringList allEvents = Translator::eventKeys();

    Calculator calculator;
    QList<QDateTime> result = adjust( calculator.calculate( now.date().addDays(-1), m_params.geo, m_params.angles, m_params.asrRatio, m_params.nightStartsIsha ), allEvents, m_params.adjustments, m_params.dstAdjust );
    result.append( adjust( calculator.calculate( now.date(), m_params.geo, m_params.angles, m_params.asrRatio, m_params.nightStartsIsha ), allEvents, m_params.adjustments, m_params.dstAdjust ) );
    result.append( adjust( calculator.calculate( now.date().addDays(1), m_params.geo, m_params.angles, m_params.asrRatio, m_params.nightStartsIsha ), allEvents, m_params.adjustments, m_params.dstAdjust ) );

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

    LOGGER("Current" << init << currentEventKey << currentEventTime << now << nextEventTime);

    qint64 diff = nextEventTime.toMSecsSinceEpoch() - now.toMSecsSinceEpoch() + 1000; // 1 second lee way in case the OS pre-empts us too early
    m_athan.timer.start(diff);

    LOGGER("StartedTimerFor" << diff);

    if (!init)
    {
        bool playAthaan = m_athan.athaans.value(currentEventKey).toBool();
        bool playNotification = m_athan.notifications.value(currentEventKey).toBool();
        Translator t;
        QMap<QString, bool> salatMap = t.salatMap();

        LOGGER("Athaans" << playAthaan << playNotification);

        if ( playAthaan && (m_athan.prevKey != currentEventKey) && salatMap.contains(currentEventKey) )
        {
            if ( currentEventKey == key_dhuhr && now.date().dayOfWeek() == Qt::Friday && m_athan.skipJumuah ) {
                LOGGER("SkipJumuahAthanByRequest");
            } else {
                NotificationGlobalSettings g;
                NotificationMode::Type mode = g.mode();
                bool okToPlay = m_athan.profiles.value( QString::number(mode) ).toBool();

                LOGGER("okToPlay" << okToPlay);

                if (okToPlay)
                {
                    LOGGER("PlayingAthanMode" << mode);
                    QString destinationFile = currentEventKey == key_fajr ? audio_fajr_athaan : audio_athaan;

                    QString customFile = m_athan.customAthaans.value(currentEventKey).toString();

                    LOGGER("CustomFile" << customFile);

                    if ( customFile.startsWith("asset://") || QFile::exists( QUrl(customFile).toLocalFile() ) ) {
                        destinationFile = customFile;
                    }

                    LOGGER( "PlayingWithVol" << m_athan.player.volume() );

                    if (m_athan.mkw == NULL) {
                        m_athan.mkw = new MediaKeyWatcher(MediaKey::VolumeDown, this);
                        connect( m_athan.mkw, SIGNAL( shortPress(bb::multimedia::MediaKey::Type) ), this, SLOT( onShortPress(bb::multimedia::MediaKey::Type) ) );
                    }

                    m_athan.player.play(destinationFile);
                } else {
                    LOGGER("SkipAthanMode" << mode);
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

        LOGGER("PrevKey" << m_athan.prevKey);
        m_athan.prevKey = currentEventKey;
        LOGGER("CurrentPrevKey" << m_athan.prevKey);
    }
}


void Service::onShortPress(bb::multimedia::MediaKey::Type key)
{
    LOGGER( key << m_athan.player.playing() );

    if ( m_athan.player.playing() && key == MediaKey::VolumeDown )
    {
        LOGGER("StoppingAthan");
        m_athan.player.stop();
        Notification::clearEffectsForAll();
        Notification::deleteAllFromInbox();
    }
}


void Service::recalculate(QString const& path)
{
    Q_UNUSED(path);

    m_settings.sync();

    if ( m_settings.contains(KEY_CALC_LATITUDE) && m_settings.contains(KEY_CALC_LONGITUDE) && m_settings.contains(KEY_CALC_ANGLES) )
    {
        m_params.angles = Calculator::createParams( m_settings.value(KEY_CALC_ANGLES).toMap() );
        m_params.asrRatio = m_settings.value(KEY_CALC_ASR_RATIO).toReal();
        m_params.adjustments = m_settings.value(KEY_CALC_ADJUSTMENTS).toMap();
        m_params.nightStartsIsha = m_settings.value(KEY_ISHA_NIGHT).toInt() == 1;
        m_params.dstAdjust = m_settings.value(KEY_DST_ADJUST).toInt();

        m_athan.athaans = m_settings.value(KEY_ATHANS).toMap();
        m_athan.notifications = m_settings.value(KEY_NOTIFICATIONS).toMap();
        m_athan.profiles = m_settings.value(KEY_PROFILES).toMap();
        m_athan.customAthaans = m_settings.value(KEY_CUSTOM_ATHANS).toMap();
        m_athan.skipJumuah = m_settings.value(KEY_SKIP_JUMUAH).toInt() == 1;
        m_athan.player.setVolume( m_settings.contains(KEY_ATHAN_VOLUME) ? m_settings.value(KEY_ATHAN_VOLUME).toDouble() : 1 );

        QVariantList values = m_athan.athaans.values();
        values.append( m_athan.notifications.values() );

        m_athan.atLeastOneEvent = values.contains(true);
        m_athan.prevKey.clear();

        if (m_athan.atLeastOneEvent) { // if there exists at least one notification or athan, then let's do it
            timeout(true);
        } else {
            m_athan.timer.stop();
            LOGGER("UserChoseNoAthansOrNotifications");
        }
    }
}


void Service::handleInvoke(bb::system::InvokeRequest const& request) {
    Q_UNUSED(request);
}


Service::~Service() {
    QFile::remove(ACTIVE_SERVICE_FILE);
}

} // salat
