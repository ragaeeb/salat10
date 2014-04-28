#ifndef SERVICE_H_
#define SERVICE_H_

#include <bb/system/InvokeManager>
#include <bb/multimedia/MediaKey>

#include <QFileSystemWatcher>
#include <QTimer>

#include "Calculator.h"
#include "ClockUtil.h"
#include "LazyMediaPlayer.h"

namespace bb {
	class Application;

	namespace multimedia {
		class MediaKeyWatcher;
	}
}

namespace salat {

using namespace canadainc;

class Service: public QObject
{
	Q_OBJECT

	bb::system::InvokeManager m_invokeManager;
	Calculator m_calculator;
	ClockUtil m_clock;
	QFileSystemWatcher m_settingsWatcher;
	QTimer m_timer;
	LazyMediaPlayer m_player;
	bb::multimedia::MediaKeyWatcher* m_mkw;

	Service(bb::Application * app);

signals:
	void currentEventChanged(QVariantList const& currentNext);

private slots:
	void handleInvoke(const bb::system::InvokeRequest &);
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
