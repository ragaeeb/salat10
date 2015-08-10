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

	void scheduleCallback(qint64 t, qint64 now);
	void saveLocation(QString const& country, QString city, qreal latitude, qreal longitude, QString const& region=QString());

signals:
	void currentEventChanged();
    void mapDataLoaded(QVariantList const& data);
    void locationsFound(QVariant const& result);

private slots:
    void requestComplete(QVariant const& cookie, QByteArray const& data, bool error);
	void timeout();

public:
	NotificationThread(DataModelWrapper* model, QObject* parent=NULL);
	virtual ~NotificationThread();

	Q_SLOT void fetchCheckins();
    Q_INVOKABLE void geoLookup(QString const& location);
    Q_SLOT void ipLookup();
};

} /* namespace salat */
#endif /* NOTIFICATIONTHREAD_H_ */
