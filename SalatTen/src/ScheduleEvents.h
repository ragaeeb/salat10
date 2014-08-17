#ifndef SCHEDULEEVENT_H_
#define SCHEDULEEVENT_H_

#include <QObject>
#include <QRunnable>
#include <QMap>

namespace salat {

class ScheduleEvents : public QObject, public QRunnable
{
	Q_OBJECT

	int m_numDays;
	QMap<QString,int> m_events;
	qint64 m_accountId;
	bool m_quit;

signals:
	void progress(int progress, int total);

public:
	ScheduleEvents(int numDays, QMap<QString,int> const& events, qint64 accountId);
	virtual ~ScheduleEvents();

	Q_SLOT void cancel();
	void run();
};

} /* namespace salat10 */
#endif /* SCHEDULEEVENT_H_ */
