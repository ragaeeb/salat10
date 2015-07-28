#ifndef SERVICE_H_
#define SERVICE_H_

#include <bb/system/InvokeManager>
#include <bb/multimedia/MediaKey>

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
    bool nightStartsIsha;
    int dstAdjust;
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
	QSettings m_settings;
	Params m_params;
	AthanHelpers m_athan;

signals:
	void currentEventChanged(QVariantList const& currentNext);
	void initialize();

private slots:
    void onAthanStateChanged();
    void error(QString const& message);
	void handleInvoke(const bb::system::InvokeRequest &);
	void init();
    void onShortPress(bb::multimedia::MediaKey::Type key);
	void recalculate(QString const& key=QString());
    void timeout(bool init=false);

public:
    Service(bb::Application * app);
	~Service();
};

}

#endif /* SERVICE_H_ */
