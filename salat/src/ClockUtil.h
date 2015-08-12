#ifndef CLOCKUTIL_H_
#define CLOCKUTIL_H_

#include <QObject>

#include <bb/AbstractBpsEventHandler>

namespace canadainc {

class ClockUtil :  public QObject, public bb::AbstractBpsEventHandler
{
	Q_OBJECT

	bool m_initialized;

signals:
	void clockSettingsChanged();

protected:
    void event(bps_event_t* event);

public:
	ClockUtil(QObject* parent=NULL);
	virtual ~ClockUtil();
};

} /* namespace canadainc */
#endif /* CLOCKUTIL_H_ */
