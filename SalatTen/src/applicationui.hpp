#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include "DatabaseBoundary.h"
#include "DataModelWrapper.h"
#include "DeviceUtils.h"
#include "InvokeHelper.h"
#include "LazyMediaPlayer.h"
#include "LazySceneCover.h"
#include "LocaleUtil.h"
#include "NotificationThread.h"
#include "Offloader.h"
#include "Persistance.h"

#include <bb/system/CardDoneMessage>

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

class ApplicationUI : public QObject
{
	Q_OBJECT

    LocaleUtil m_locale;
	Persistance m_persistance;
	LazySceneCover m_cover;
	DatabaseBoundary m_sql;
    DataModelWrapper m_model;
    NotificationThread m_notification;
    DeviceUtils m_device;
    Offloader m_offloader;
    InvokeHelper m_invoke;

    void init(QString const& qml);
    void initDefaultValues();

signals:
	void initialize();
	void lazyInitComplete();

private slots:
    void childCardDone(bb::system::CardDoneMessage const& message=bb::system::CardDoneMessage());
    void invoked(bb::system::InvokeRequest const& request);
    void lazyInit();
    void onFullScreen();
    void reverseLookupFinished(QGeoAddress const& g, QPointF const& point, bool error);

public:
    ApplicationUI(InvokeManager* i);
    virtual ~ApplicationUI();

    Q_INVOKABLE QObject* refreshLocation();
    Q_INVOKABLE void setCustomAthaans(QStringList const& keys, QString const& uri=QString());
    Q_INVOKABLE void saveIqamah(QString const& key, QDateTime const& time);
    Q_INVOKABLE void removeIqamah(QString const& key);
};

} // salat

#endif /* ApplicationUI_HPP_ */
