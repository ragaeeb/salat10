#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include "customsqldatasource.h"
#include "DataModelWrapper.h"
#include "LazyMediaPlayer.h"
#include "LazySceneCover.h"
#include "LocaleUtil.h"
#include "NotificationThread.h"
#include "Persistance.h"

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

	Persistance m_persistance;
	LocaleUtil m_locale;
	LazySceneCover m_cover;
	CustomSqlDataSource m_sql;
	CleanupEvents* m_cleanup;
	ScheduleEvents* m_schedule;
    DataModelWrapper m_model;
    NotificationThread m_notification;

    ApplicationUI(bb::cascades::Application *app);

signals:
    void accountsImported(QVariantList const& qvl);
	void operationProgress(int current, int total);
	void operationComplete(QString const& toastMessage, QString const& icon);
	void initialize();
	void lazyInitComplete();

private slots:
    void handleExportComplete(QObject* obj);
    void handleCleanupComplete(QObject* obj);
    void lazyInit();
    void onFullScreen();
    void reverseLookupFinished(QGeoAddress const& g, QPointF const& point, bool error);
    void terminateThreads();

public:
	static void create(bb::cascades::Application* app);
    virtual ~ApplicationUI();

    Q_INVOKABLE void loadAccounts();
    Q_INVOKABLE void exportToCalendar(int numDays, QVariantList const& events, qint64 accountId);
    Q_INVOKABLE void renderMap(QObject* mapView, qreal latitude, qreal longitude, QString const& name, QString const& event, bool focus=false);
    Q_INVOKABLE QObject* refreshLocation();
    Q_INVOKABLE void cleanupCalendarEvents();
    Q_INVOKABLE void setCustomAthaans(QStringList const& keys, QString const& uri=QString());
    Q_INVOKABLE void launchBrowser(QString const& uri);
    Q_INVOKABLE void saveIqamah(QString const& key, QDateTime const& time);
    Q_INVOKABLE void removeIqamah(QString const& key);
    bool hasCalendarAccess();
};

} // salat

#endif /* ApplicationUI_HPP_ */
