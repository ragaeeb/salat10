#ifndef NOTIFICATIONTHREAD_H_
#define NOTIFICATIONTHREAD_H_

#include <QTimer>

#include "ClockUtil.h"
#include "NetworkProcessor.h"

namespace salat {

using namespace bb::cascades;
using namespace canadainc;

class DataModelWrapper;

class NotificationThread : public QObject
{
	Q_OBJECT

    ClockUtil m_clock;
	DataModelWrapper* m_model;
	QTimer m_timer;
	QMap<QString, QString> m_athaanMap;
    NetworkProcessor m_network;
    QVariantMap m_response;
    QFutureWatcher<QVariantMap> m_extractor;
    bool m_pendingRequest;

    void processUserCheckin(QByteArray const& data, bool error);
    void processCheckins(QString const& result);
    void processIP1(QByteArray const& data);
    void processIP2(QByteArray const& data);
	void scheduleCallback(qint64 t, qint64 now);
	void saveLocation(QString const& country, QString city, qreal latitude, qreal longitude, QString const& region=QString());

signals:
	void currentEventChanged();
	void databaseUpdated();
    void dbUpdateAvailable(qint64 dbSize, qint64 dbVersion, bool forced);
    void locationsFound(QVariant const& result);
    void mapDataLoaded(QVariantList const& data);
    void transferProgress(QVariant const& cookie, qint64 bytesSent, qint64 bytesTotal);

private slots:
    void onExtracted();
    void requestComplete(QVariant const& cookie, QByteArray const& data, bool error);
	void timeout();

public:
	NotificationThread(DataModelWrapper* model, QObject* parent=NULL);
	virtual ~NotificationThread();

    Q_SLOT void clearPendingCheckin();
    Q_SLOT void downloadPlugins();
	Q_SLOT void fetchCheckins();
    Q_INVOKABLE void geoLookup(QString const& location);
    Q_SLOT void ipLookup();
};

} /* namespace salat */
#endif /* NOTIFICATIONTHREAD_H_ */
