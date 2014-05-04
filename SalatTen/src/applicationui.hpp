#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include <bb/system/InvokeManager>

#include <QTimer>

#include "ClockUtil.h"
#include "customsqldatasource.h"
#include "LazyMediaPlayer.h"
#include "LazySceneCover.h"
#include "LocaleUtil.h"
#include "NetworkProcessor.h"
#include "NotificationThread.h"

namespace bb {
	namespace cascades {
		class Application;
	}
}

namespace QtMobilitySubset {
    class QGeoAddress;
}

namespace salat {

using namespace canadainc;
using namespace QtMobilitySubset;

class CleanupEvents;
class ScheduleEvents;

class ApplicationUI : public QObject
{
	Q_OBJECT
	Q_PROPERTY(bool hasCalendarAccess READ hasCalendarAccess)
	Q_PROPERTY(bool atLeastOneAthanScheduled READ atLeastOneAthanScheduled)

	LocaleUtil m_locale;
	NotificationThread m_notification;
	LazySceneCover m_cover;
	ClockUtil m_clock;
	QTimer m_timer;
	CustomSqlDataSource m_sql;
	bb::system::InvokeManager m_invokeManager;
	CleanupEvents* m_cleanup;
	ScheduleEvents* m_schedule;
	NetworkProcessor m_network;

    ApplicationUI(bb::cascades::Application *app);

signals:
    void accountsImported(QVariantList const& qvl);
	void operationProgress(int current, int total);
	void operationComplete(QString const& toastMessage, QString const& icon);
	void initialize();
	void mapDataLoaded(QVariantList const& data);

private slots:
    void handleExportComplete(QObject* obj);
    void handleCleanupComplete(QObject* obj);
    void init();
    void onFullScreen();
    void readyToCheckin(QVariantMap const& current, QVariantMap const& next);
    void requestComplete(QVariant const& cookie, QByteArray const& data);
    void reverseLookupFinished(QGeoAddress const& g, QPointF const& point, bool error);
    void terminateThreads();

public:
	static void create(bb::cascades::Application* app);
    virtual ~ApplicationUI();

    Q_INVOKABLE void loadAccounts();
    Q_INVOKABLE void exportToCalendar(int numDays, QVariantList const& events, int accountId);
    Q_INVOKABLE void renderMap(QObject* mapView, qreal latitude, qreal longitude, QString const& name, QString const& event, bool focus=false);
    Q_INVOKABLE void cleanupCalendarEvents();
    Q_INVOKABLE QObject* refreshLocation();
    Q_INVOKABLE void fetchCheckins();
    Q_INVOKABLE void setCustomAthaans(QStringList const& keys, QString const& uri=QString());
    Q_INVOKABLE void launchUrl(QString const& url);
    bool atLeastOneAthanScheduled();
    bool hasCalendarAccess();
};

} // salat

#endif /* ApplicationUI_HPP_ */
