#include "precompiled.h"

#include "DataModelWrapper.h"
#include "Coordinates.h"
#include "Logger.h"
#include "SalatParameters.h"
#include "SalatUtils.h"
#include "SolarCalculator.h"
#include "Translator.h"

#define UI_KEY "logUI"

namespace salat {

using namespace bb::cascades;
using namespace bb::platform;

DataModelWrapper::DataModelWrapper(QObject* parent) :
        QObject(parent), m_model( QStringList() << "dateValue", this ), m_empty(true)
{
    init();

	m_model.setSortingKeys( QStringList() << "dateValue" << "value" );
	m_model.setGrouping(ItemGrouping::ByFullValue);

	connect( &m_model, SIGNAL( itemAdded(QVariantList) ), this, SLOT( itemAdded(QVariantList) ) );
	connect( &m_model, SIGNAL( itemsChanged(bb::cascades::DataModelChangeType::Type, QSharedPointer<bb::cascades::DataModel::IndexMapper>) ), this, SLOT( itemsChanged(bb::cascades::DataModelChangeType::Type, QSharedPointer<bb::cascades::DataModel::IndexMapper>) ) );
}


void DataModelWrapper::init()
{
    INIT_SETTING(UI_KEY, true);
    INIT_SETTING(SERVICE_KEY, false);

    INIT_FRESH("v3.2");
    INIT_SETTING("strategy", "isna");
    INIT_SETTING("skipJumahAthaan", 1);
    INIT_SETTING("asrRatio", 1);
    INIT_SETTING("hijri", 0);

    if ( !m_persistance.contains("athaans") )
    {
        QVariantMap notifications;

        QStringList eventKeys = Translator::eventKeys();
        QMap<QString, bool> salatMap = Translator().salatMap();

        for (int i = eventKeys.size()-1; i >= 0; i--) {
            notifications[ eventKeys[i] ] = salatMap.contains( eventKeys[i] );
        }

        m_persistance.saveValueFor("athaans", notifications, false);
        m_persistance.saveValueFor("notifications", notifications, false);
    }

    if ( !m_persistance.contains("adjustments") )
    {
        QVariantMap adjustments;

        QStringList salatKeys = Translator::salatKeys();

        for (int i = salatKeys.size()-1; i >= 0; i--) {
            adjustments[ salatKeys[i] ] = 0;
        }

        m_persistance.saveValueFor("adjustments", adjustments);
    }

    if ( !m_persistance.contains("profiles") )
    {
        QVariantMap profiles;
        profiles[ QString::number(NotificationMode::Silent) ] = false;
        profiles[ QString::number(NotificationMode::Vibrate) ] = true;
        profiles[ QString::number(NotificationMode::Normal) ] = true;
        profiles[ QString::number(NotificationMode::PhoneOnly) ] = true;
        profiles[ QString::number(NotificationMode::AlertsOff) ] = false;

        m_persistance.saveValueFor("profiles", profiles, false);
    }
}


QVariantList DataModelWrapper::calculate(QDateTime local, int numDays)
{
    LOGGER(local << numDays);
	Coordinates geo = Calculator::createCoordinates( local, m_persistance.getValueFor("latitude"), m_persistance.getValueFor("longitude") );
	SalatParameters angles = Calculator::createParams( m_persistance.getValueFor("angles").toMap() );
	qreal asrRatio = m_persistance.getValueFor("asrRatio").toReal();

	QVariantList wrapped;
	QStringList keys = Translator::eventKeys();
	QMap<QString, bool> salatMap = Translator().salatMap();

	QVariantMap adjustments = m_persistance.getValueFor("adjustments").toMap();
	QVariantMap athaans = m_persistance.getValueFor("athaans").toMap();
	QVariantMap notifications = m_persistance.getValueFor("notifications").toMap();

	for (int i = 0; i < numDays; i++)
	{
		m_mutex.lock();
		QList<QDateTime> result = m_calculator.calculate( local.date(), geo, angles, asrRatio ); // use Shafii ratio of 1:1 object:shadow
		//	result << local.addSecs(30) << local.addSecs(60) << local.addSecs(90) << local.addSecs(120) << local.addSecs(150) << local.addSecs(180) << local.addSecs(210) << local.addSecs(240) << local.addSecs(270);
		m_mutex.unlock();

		for (int j = 0; j < result.size(); j++)
		{
			QString key = keys[j];
			int adjust = adjustments.value(key).toInt();

			QVariantMap map;
			map["key"] = key;
			map["value"] = result[j].addSecs(adjust*60);
			map["dateValue"] = result[j].date();
			map["isSalat"] = salatMap.contains(key);

			if ( athaans.contains(key) ) {
				map["athaan"] = athaans.value(key);
			}

            if ( notifications.contains(key) ) {
                map["notification"] = notifications.value(key);
            }

			wrapped << map;
		}

		local = local.addDays(1);
	}

    return wrapped;
}


QVariantList DataModelWrapper::matchValue(QDateTime const& reference)
{
	QVariantMap map;
	map["dateValue"] = reference.date();
	map["value"] = reference;

	QVariantList next = m_model.upperBound(map);

	if ( next.isEmpty() )
	{
		if ( m_model.isEmpty() ) { // for past midnight but before fajr
			calculateAndAppend( reference.addDays(-1) );
		}

		calculateAndAppend(reference);
		next = m_model.upperBound(map);
	}

	return next;
}


QVariantMap DataModelWrapper::getCurrent(QDateTime const& reference)
{
	QVariantList next = matchValue(reference);

	QVariantList current = m_model.before(next);
	QVariantMap currentMap = m_model.data(current).toMap();
	currentMap["index"] = current;

	return currentMap;
}


QVariantMap DataModelWrapper::getNext(QDateTime const& reference)
{
	QVariantList next = matchValue(reference);

	QVariantMap nextMap = m_model.data(next).toMap();
	nextMap["index"] = next;

	return nextMap;
}


void DataModelWrapper::loadBeginning()
{
	QDateTime reference = m_model.data( m_model.first() ).toMap().value("value").toDateTime().addDays(-1);
	calculateAndAppend(reference);
}


void DataModelWrapper::calculateAndAppend(QDateTime const& reference)
{
	QVariantList wrapped = calculate(reference);
	m_model.insertList(wrapped);
}


void DataModelWrapper::loadMore()
{
	if ( !m_model.isEmpty() ) {

		QVariantList i = m_model.last();
		QString fajrKey = Translator::key_fajr;

		while (true) { // backtrack until you hit fajr
			QVariantList prev = m_model.before(i);

			if ( prev.isEmpty() ) {
				LOGGER("How did I get here?");
				return;
			} else if ( m_model.data(prev).toMap().value("key") != fajrKey ) {
				i = prev;
			} else {
				break;
			}
		}

		QDateTime reference = m_model.data(i).toMap().value("value").toDateTime().addDays(1);
		calculateAndAppend(reference);
	}
}


Persistance* DataModelWrapper::getPersist() {
	return &m_persistance;
}


void DataModelWrapper::reset() {
	m_model.clear();
}


Calculator* DataModelWrapper::getCalculator() {
	return &m_calculator;
}


QVariant DataModelWrapper::getModel() {
	return QVariant::fromValue(&m_model);
}


bool DataModelWrapper::isEmpty() const {
    return m_empty;
}


Translator* DataModelWrapper::getTranslator() {
	return &m_translator;
}


void DataModelWrapper::itemAdded(QVariantList indexPath)
{
    Q_UNUSED(indexPath);

    if (m_empty) {
        m_empty = false;
        emit emptyChanged();
    }
}


void DataModelWrapper::itemsChanged(bb::cascades::DataModelChangeType::Type eChangeType, QSharedPointer<bb::cascades::DataModel::IndexMapper> indexMapper)
{
    Q_UNUSED(indexMapper);
    Q_UNUSED(eChangeType);

    if ( m_empty != m_model.isEmpty() ) {
        m_empty = m_model.isEmpty();
        emit emptyChanged();
    }
}


DataModelWrapper::~DataModelWrapper() {
	m_model.setParent(NULL);
}

} /* namespace salat */
