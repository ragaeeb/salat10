#ifndef SERVICE_H_
#define SERVICE_H_

#include <bb/system/InvokeManager>
#include <bb/multimedia/MediaKey>

#include <bb/network/PushService>

#include <QFileSystemWatcher>
#include <QTimer>

#include "Calculator.h"
#include "ClockUtil.h"
#include "Coordinates.h"
#include "LazyMediaPlayer.h"
#include "SalatParameters.h"

namespace bb {
	class Application;

	namespace multimedia {
		class MediaKeyWatcher;
	}
}

namespace salat {

using namespace canadainc;

struct Params
{
    Coordinates geo;
    SalatParameters angles;
    qreal asrRatio;
    QVariantMap adjustments;
};

struct AthanHelpers
{
    QVariantMap athaans;
    QVariantMap notifications;
    QVariantMap profiles;
    QVariantMap customAthaans;
    bool skipJumuah;
    LazyMediaPlayer player;
    bb::multimedia::MediaKeyWatcher* mkw;
    QString prevKey;
    QTimer timer;
    bool atLeastOneEvent;
};

class Service: public QObject
{
	Q_OBJECT

	bb::system::InvokeManager m_invokeManager;
	ClockUtil m_clock;
	QFileSystemWatcher m_settingsWatcher;
	bb::network::PushService m_pushService;
	QSettings m_settings;
	Params m_params;
	AthanHelpers m_athan;

	Service(bb::Application * app);

signals:
	void currentEventChanged(QVariantList const& currentNext);
	void initialize();

private slots:
    void createChannelCompleted(bb::network::PushStatus const&, QString const&);
    void createSessionCompleted(const bb::network::PushStatus&);
	void handleInvoke(const bb::system::InvokeRequest &);
	void init();
	void onPlayingStateChanged();
    void onShortPress(bb::multimedia::MediaKey::Type key);
	void recalculate(QString const& key=QString());
    void timeout(bool init=false);

public:
	~Service();
	static void create(bb::Application* app);
};

}

#endif /* SERVICE_H_ */
