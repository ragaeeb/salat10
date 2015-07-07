#ifndef INVOKEHELPER_H_
#define INVOKEHELPER_H_

#include <bb/system/InvokeRequest>

namespace bb {
    namespace system {
        class InvokeManager;
    }
}

namespace salat {

using namespace bb::system;

class InvokeHelper : public QObject
{
    Q_OBJECT

    bb::system::InvokeRequest m_request;
    QObject* m_root;
    InvokeManager* m_invokeManager;

public:
    InvokeHelper(InvokeManager* invokeManager);
    virtual ~InvokeHelper();

    void init(QString const& qmlDoc, QMap<QString, QObject*> const& context, QObject* parent);
    QString invoked(bb::system::InvokeRequest const& request);
    void process();
    void registerQmlTypes();
};

} /* namespace admin */

#endif /* INVOKEHELPER_H_ */
