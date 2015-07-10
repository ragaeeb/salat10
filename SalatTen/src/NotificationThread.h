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

signals:
	void currentEventChanged();
    void mapDataLoaded(QVariantList const& data);
    void locationsFound(QVariant const& result);

private slots:
    void onUserIdFound(QVariant userId);
    void readyToCheckin(QVariantMap const& current, QVariantMap const& next);
    void requestComplete(QVariant const& cookie, QByteArray const& data, bool error);
	void timeout();

public:
	NotificationThread(DataModelWrapper* model, QObject* parent=NULL);
	virtual ~NotificationThread();

    Q_INVOKABLE void fetchCheckins();
    Q_INVOKABLE void geoLookup(QString const& location);
};

} /* namespace salat */
#endif /* NOTIFICATIONTHREAD_H_ */
