#ifndef CLEANUPEVENTS_H_
#define CLEANUPEVENTS_H_

#include <QObject>
#include <QRunnable>

namespace salat {

class CleanupEvents : public QObject, public QRunnable
{
	Q_OBJECT

	bool m_quit;

signals:
	void progress(int current, int total);

public:
	CleanupEvents();
	virtual ~CleanupEvents();

	Q_SLOT void cancel();
	void run();
};

} /* namespace salat10 */
#endif /* CLEANUPEVENTS_H_ */
