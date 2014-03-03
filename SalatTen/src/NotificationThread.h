#ifndef NOTIFICATIONTHREAD_H_
#define NOTIFICATIONTHREAD_H_

#include <QTimer>

#include "DataModelWrapper.h"
#include "NetworkProcessor.h"

namespace salat {

using namespace bb::cascades;
using namespace canadainc;

class NotificationThread : public QObject
{
	Q_OBJECT
	Q_PROPERTY(bool calculationFeasible READ calculationFeasible)

	DataModelWrapper m_model;
	QTimer m_timer;
	QMap<QString, QString> m_athaanMap;
    NetworkProcessor m_network;

	void scheduleCallback(qint64 t, qint64 now);

signals:
	void currentEventChanged();
	void readyToCheckin(QVariantMap const& current, QVariantMap const& next);

private slots:
	void recalculate(QString const& key);
	void timeout(bool init=false);

public:
	NotificationThread(QObject* parent=NULL);
	virtual ~NotificationThread();

	Q_SLOT void run();
    bool calculationFeasible();
	DataModelWrapper* getModel();
};

} /* namespace salat */
#endif /* NOTIFICATIONTHREAD_H_ */
