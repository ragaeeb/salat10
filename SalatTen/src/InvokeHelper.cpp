#include "precompiled.h"

#include "InvokeHelper.h"
#include "CardUtils.h"
#include "CircularSlider.h"
#include "CompassSensor.hpp"
#include "Logger.h"
#include "QueryId.h"

namespace salat {

using namespace bb::system;
using namespace canadainc;

InvokeHelper::InvokeHelper(InvokeManager* invokeManager) :
        m_root(NULL), m_invokeManager(invokeManager)
{
}


void InvokeHelper::init(QString const& qmlDoc, QMap<QString, QObject*> const& context, QObject* parent)
{
    qmlRegisterUncreatableType<QueryId>("com.canadainc.data", 1, 0, "QueryId", "Can't instantiate");
    qmlRegisterType<QTimer>("com.canadainc.data", 1, 0, "QTimer");

    m_root = CardUtils::initAppropriate(qmlDoc, context, parent);
}


QString InvokeHelper::invoked(bb::system::InvokeRequest const& request)
{
    LOGGER( request.action() << request.target() << request.mimeType() << request.metadata() << request.uri().toString() << QString( request.data() ) );

    QString target = request.target();

    QMap<QString,QString> targetToQML;
    //targetToQML[TARGET_EDIT_INDIVIDUAL] = "CreateIndividualPage.qml";

    QString qml = targetToQML.value(target);

    if ( qml.isNull() ) {
        qml = "CardPage.qml";
    }

    m_request = request;
    m_request.setTarget(target);

    return qml;
}


void InvokeHelper::process()
{
    QString target = m_request.target();

    if ( !target.isEmpty() )
    {
    }
}


void InvokeHelper::registerQmlTypes()
{
    qmlRegisterType<CircularSlider>("com.canadainc.data", 1, 0, "CircularSlider");
    qmlRegisterType<CompassSensor>("com.canadainc.data", 1, 0, "CompassSensor");
    qmlRegisterType<bb::cascades::places::PlacePicker>("bb.cascades.places", 1, 0, "PlacePicker");
    qmlRegisterUncreatableType<bb::cascades::places::SelectedPlace>("bb.cascades.places", 1, 0, "SelectedPlace", "Class SelectedPlace is not instantiable.");
    qmlRegisterUncreatableType<bb::platform::NotificationMode>("bb.platform", 1, 0, "NotificationMode", "Can't instantiate");
}


InvokeHelper::~InvokeHelper()
{
}

} /* namespace admin */
