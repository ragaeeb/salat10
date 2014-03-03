#include "precompiled.h"

#include "service.hpp"
#include "Coordinates.h"
#include "Logger.h"
#include "IOUtils.h"
#include "SalatParameters.h"
#include "Translator.h"

namespace {

const char* audio_fajr_athaan = "asset:///audio/athaan_fajr.mp3";
const char* audio_athaan = "asset:///audio/athaan.mp3";

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

using namespace bb::system;
using namespace bb::platform;
using namespace bb::multimedia;

Service::Service(bb::Application* app) : QObject(app), m_mkw(NULL)
{
    QSettings s;

    if ( !QFile::exists( s.fileName() ) )
    {
        s.setValue( "init", QDateTime::currentMSecsSinceEpoch() );
        s.sync();
    }

	m_settingsWatcher.addPath( s.fileName() );

	m_timer.setSingleShot(true);
	connect( &m_timer, SIGNAL( timeout() ), this, SLOT( timeout() ) );
	connect( &m_settingsWatcher, SIGNAL( fileChanged(QString const&) ), this, SLOT( recalculate(QString const&) ) );
	connect( &m_clock, SIGNAL( clockSettingsChanged() ), this, SLOT( recalculate() ) );
	connect( &m_invokeManager, SIGNAL( invoked(const bb::system::InvokeRequest&) ), this, SLOT( handleInvoke(const bb::system::InvokeRequest&) ) );

	recalculate();
}


void Service::timeout(bool init)
{
	LOGGER("Timeout!" << init);
	QDateTime now = QDateTime::currentDateTime();
	LOGGER("Now" << now);
	QSettings settings;
	Coordinates geo = Calculator::createCoordinates( now, settings.value("latitude"), settings.value("longitude") );
	SalatParameters angles = Calculator::createParams( settings.value("angles").toMap() );
	qreal asrRatio = settings.value("asrRatio").toReal();
	QVariantMap adjustments = settings.value("adjustments").toMap();

	QStringList allEvents = Translator::eventKeys();

	QList<QDateTime> result = adjust( m_calculator.calculate( now.date().addDays(-1), geo, angles, asrRatio ), allEvents, adjustments );
	result.append( adjust( m_calculator.calculate( now.date(), geo, angles, asrRatio ), allEvents, adjustments ) );
	result.append( adjust( m_calculator.calculate( now.date().addDays(1), geo, angles, asrRatio ), allEvents, adjustments ) );

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

	LOGGER("Current" << currentEventKey << currentEventTime);
	LOGGER("Now:" << now << "next: " << nextEventTime);

	qint64 diff = nextEventTime.toMSecsSinceEpoch() - now.toMSecsSinceEpoch();
	m_timer.start(diff);

	LOGGER("Started timer for " << diff);

	if (!init)
	{
		QVariantMap athaans = settings.value("athaans").toMap();
		bool playAthaan = athaans.value(currentEventKey).toBool();

		LOGGER("Athaans" << athaans << playAthaan << currentEventKey);

        if (playAthaan) {
            LOGGER("Should play maybe?");

            if ( currentEventKey == Translator::key_dhuhr && now.date().dayOfWeek() == Qt::Friday && settings.value("skipJumahAthaan").toInt() == 1 ) {
                LOGGER("Skipping athaan because it is Friday and user chose not to play it on Ju'muah.");
            } else {
                LOGGER("ELSE!" << now);

                NotificationGlobalSettings g;
                NotificationMode::Type mode = g.mode();
                int profile = settings.value("respectProfile").toInt();
                bool okToPlay = profile == 0 || (profile == 1 && mode > NotificationMode::Vibrate) || (profile == 2 && mode > NotificationMode::Silent);
                Translator t;
                QMap<QString, bool> salatMap = t.salatMap();

                LOGGER("okToPlay" << okToPlay << "map" << salatMap << currentEventKey);

                if ( okToPlay && salatMap.contains(currentEventKey) ) {
                    LOGGER("Playing athaan" << profile << "mode" << mode);
                    QString destinationFile = currentEventKey == Translator::key_fajr ? audio_fajr_athaan : audio_athaan;

                    QString customFile = settings.value("customAthaans").toMap().value(currentEventKey).toString();

                    LOGGER("Custom file" << customFile);

                    if ( QFile::exists(customFile) ) {
                        destinationFile = customFile;
                    }

                    LOGGER("destination file" << destinationFile);

                    m_player.play(destinationFile);

                    if (m_mkw == NULL) {
                        m_mkw = new MediaKeyWatcher(MediaKey::PlayPause, this);
                        connect( m_mkw, SIGNAL( shortPress(bb::multimedia::MediaKey::Type) ), this, SLOT( onShortPress(bb::multimedia::MediaKey::Type) ) );
                    }
                } else {
                    LOGGER("Skipping athaan" << profile << "mode" << mode);
                }

                Notification n;
                n.setTitle("Salat10");
                n.setBody( t.render(currentEventKey) );
                n.setTimestamp(currentEventTime);
                n.setIconUrl( QUrl( QString("file:///usr/share/icons/clock_alarm.png") ) );
                n.notify();
            }
		} else {
			LOGGER("Don't play athaan for this key");
		}
	}
}


void Service::onShortPress(bb::multimedia::MediaKey::Type key)
{
	LOGGER("========== SHORT PRESSED!!!!" << key << m_player.playing());

	if ( m_player.playing() && key == MediaKey::PlayPause ) {
		LOGGER("===== STOPPING");
		m_player.stop();
	}
}


void Service::recalculate(QString const& key)
{
	LOGGER("Recalculate!" << key);

	QSettings settings;

	if ( settings.contains("latitude") && settings.contains("longitude") && settings.contains("angles") )
	{
		LOGGER("Resetted!");
		timeout(true);
	}
}


void Service::create(bb::Application* app) {
	new Service(app);
}


void Service::handleInvoke(const bb::system::InvokeRequest & request)
{
	LOGGER("handleInvoke!" << request.action());

	if (request.action().compare("com.canadainc.SalatTenService.RESET") == 0) {
		recalculate();
	}
}


Service::~Service()
{
}

} // salat
