#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include "customsqldatasource.h"
#include "DataModelWrapper.h"
#include "DeviceUtils.h"
#include "LazyMediaPlayer.h"
#include "LazySceneCover.h"
#include "LocaleUtil.h"
#include "NotificationThread.h"
#include "Persistance.h"

#include <bb/system/CardDoneMessage>
#include <bb/system/LocaleHandler>

#include <bb/ImageData>
#include <bb/cascades/ImageView>

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
using namespace bb::system;

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
    bb::system::LocaleHandler m_timeRender;
    bb::cascades::Image m_blurred;
    DeviceUtils m_device;

    void init(QString const& qml);

signals:
    void accountsImported(QVariantList const& qvl);
	void operationProgress(int current, int total);
	void operationComplete(QString const& toastMessage, QString const& icon);
	void initialize();
	void lazyInitComplete();

private slots:
    void childCardDone(bb::system::CardDoneMessage const& message=bb::system::CardDoneMessage());
    void handleExportComplete(QObject* obj);
    void handleCleanupComplete(QObject* obj);
    void invoked(bb::system::InvokeRequest const& request);
    void lazyInit();
    void onFullScreen();
    void reverseLookupFinished(QGeoAddress const& g, QPointF const& point, bool error);
    void terminateThreads();
    void onBlurred();

public:
    ApplicationUI(InvokeManager* i);
    virtual ~ApplicationUI();

    Q_INVOKABLE void loadAccounts();
    Q_INVOKABLE void exportToCalendar(int numDays, QVariantList const& events, qint64 accountId);
    Q_INVOKABLE void renderMap(QObject* mapView, qreal latitude, qreal longitude, QString const& name, QString const& event, bool focus=false);
    Q_INVOKABLE QObject* refreshLocation();
    Q_INVOKABLE void cleanupCalendarEvents();
    Q_INVOKABLE void setCustomAthaans(QStringList const& keys, QString const& uri=QString());
    Q_INVOKABLE void saveIqamah(QString const& key, QDateTime const& time);
    Q_INVOKABLE void removeIqamah(QString const& key);
    bool hasCalendarAccess();
    Q_INVOKABLE QString renderStandardTime(QDateTime const& theTime);
    Q_INVOKABLE void blur(bb::cascades::ImageView* i, QString const& imageSrc);
};

} // salat

#endif /* ApplicationUI_HPP_ */
