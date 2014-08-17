#include "precompiled.h"

#include "DataModelWrapper.h"
#include "Coordinates.h"
#include "DiffUtil.h"
#include "Logger.h"
#include "Persistance.h"
#include "SolarCalculator.h"
#include "Translator.h"

namespace salat {

using namespace bb::cascades;

DataModelWrapper::DataModelWrapper(Persistance* p, QObject* parent) :
        QObject(parent), m_persistance(p),
        m_model( QStringList() << "dateValue", this )
{
	m_model.setSortingKeys( QStringList() << "dateValue" << "value" );
	m_model.setGrouping(ItemGrouping::ByFullValue);

	connect( &m_model, SIGNAL( itemAdded(QVariantList) ), this, SLOT( itemAdded(QVariantList) ) );
	connect( &m_model, SIGNAL( itemsChanged(bb::cascades::DataModelChangeType::Type, QSharedPointer<bb::cascades::DataModel::IndexMapper>) ), this, SLOT( itemsChanged(bb::cascades::DataModelChangeType::Type, QSharedPointer<bb::cascades::DataModel::IndexMapper>) ) );

	connect( p, SIGNAL( settingChanged(QString const&) ), this, SLOT( settingChanged(QString const&) ), Qt::QueuedConnection );
}


void DataModelWrapper::lazyInit()
{
    updateCache( QStringList() << "angles" << "asrRatio" << "adjustments" << "athaans" << "notifications" << "iqamahs" << "latitude" << "longitude" );
}


QVariantList DataModelWrapper::calculate(QDateTime local, int numDays)
{
    QMap<QString, bool> salatMap = Translator().salatMap();
    Coordinates geo = Calculator::createCoordinates(local, m_cache.latitude, m_cache.longitude);

	QVariantList wrapped;
	QStringList keys = Translator::eventKeys();

	for (int i = 0; i < numDays; i++)
	{
		QList<QDateTime> result = m_calculator.calculate( local.date(), geo, m_cache.angles, m_cache.asrRatio );
		//	result << local.addSecs(30) << local.addSecs(60) << local.addSecs(90) << local.addSecs(120) << local.addSecs(150) << local.addSecs(180) << local.addSecs(210) << local.addSecs(240) << local.addSecs(270);

		LOGGER(result);

		for (int j = 0; j < result.size(); j++)
		{
			QString key = keys[j];
			int adjust = m_cache.adjustments.value(key);

			QVariantMap map;
			map["key"] = key;
			map["value"] = result[j].addSecs(adjust*60);
			map["dateValue"] = result[j].date();
			map["isSalat"] = salatMap.contains(key);

			if ( m_cache.iqamahs.contains(key) )
			{
	            QDateTime iqamah = QDateTime( result[j].date(), m_cache.iqamahs.value(key) );
	            map["iqamah"] = iqamah;
			}

			if ( m_cache.athaans.contains(key) ) {
				map["athaan"] = m_cache.athaans.value(key);
			}

            if ( m_cache.notifications.contains(key) ) {
                map["notification"] = m_cache.notifications.value(key);
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
    if ( m_cache.feasible() )
    {
        QVariantList wrapped = calculate(reference);
        m_model.insertList(wrapped);
    }
}


void DataModelWrapper::applyDiff(QString const& settingKey, QString const& itemKey)
{
    int sections = m_model.childCount( QVariantList() );
    QVariantMap settingValue = m_persistance->getValueFor(settingKey).toMap();

    for (int i = 0; i < sections; i++)
    {
        int childrenInSection = m_model.childCount( QVariantList() << i );

        for (int j = 0; j < childrenInSection; j++)
        {
            QVariantList indexPath = QVariantList() << i << j;
            QVariantMap current = m_model.data(indexPath).toMap();
            current[itemKey] = settingValue.value( current.value("key").toString() );
            m_model.updateItem(indexPath, current);
        }
    }
}


void DataModelWrapper::loadMore()
{
	if ( !m_model.isEmpty() ) {

		QVariantList i = m_model.last();

		while (true) { // backtrack until you hit fajr
			QVariantList prev = m_model.before(i);

			if ( prev.isEmpty() ) {
				LOGGER("[HOW_THE_HECK_DID_I_GET_HERE]");
				return;
			} else if ( m_model.data(prev).toMap().value("key") != key_fajr ) {
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
	return m_persistance;
}


Calculator* DataModelWrapper::getCalculator() {
	return &m_calculator;
}


QVariant DataModelWrapper::getModel() {
	return QVariant::fromValue(&m_model);
}


Translator* DataModelWrapper::getTranslator() {
	return &m_translator;
}


void DataModelWrapper::updateCache(QStringList const& keys)
{
    bool needsRefresh = false;

    foreach (QString const& key, keys)
    {
        if (key == "angles") {
            m_cache.angles = Calculator::createParams( m_persistance->getValueFor("angles").toMap() );
            needsRefresh = true;
        } else if (key == "asrRatio") {
            m_cache.asrRatio = m_persistance->getValueFor("asrRatio").toReal();
            needsRefresh = true;
        } else if (key == "adjustments") {
            QVariantMap adjustments = m_persistance->getValueFor("adjustments").toMap();
            m_cache.adjustments.clear();

            foreach ( QString const& key, adjustments.keys() ) {
                m_cache.adjustments.insert( key, adjustments[key].toInt() );
            }

            needsRefresh = true;
        } else if (key == "athaans") {
            m_cache.athaans = m_persistance->getValueFor("athaans").toMap();
            applyDiff(key, "athaan");
        } else if (key == "notifications") {
            m_cache.notifications = m_persistance->getValueFor("notifications").toMap();
            applyDiff(key, "notification");
        } else if (key == "iqamahs") {
            QVariantMap iqamahs = m_persistance->getValueFor("iqamahs").toMap();
            m_cache.iqamahs.clear();
            LOGGER("changed" << iqamahs);

            foreach ( QString const& key, iqamahs.keys() ) {
                m_cache.iqamahs.insert( key, iqamahs[key].toTime() );
            }

            LOGGER("difing" << m_cache.iqamahs);
            DiffUtil::diffIqamahs(&m_model, m_cache.iqamahs);
        } else if (key == "latitude") {
            m_cache.latitude = m_persistance->getValueFor("latitude").toReal();
            needsRefresh = true;
        } else if (key == "longitude") {
            m_cache.longitude = m_persistance->getValueFor("longitude").toReal();
            needsRefresh = true;
        }
    }

    if (needsRefresh) {
        refreshNeeded();
    }
}


void DataModelWrapper::settingChanged(QString const& key) {
    updateCache( QStringList() << key );
}


void DataModelWrapper::refreshNeeded()
{
    m_model.clear();
    emit recalculationNeeded();
}


bool DataModelWrapper::atLeastOneAthanScheduled()
{
    QVariantList values = m_cache.athaans.values();
    return values.contains(true);
}


bool DataModelWrapper::calculationFeasible() const {
    return m_cache.feasible();
}


bool Cache::feasible() const {
    return latitude != 0 && longitude != 0 && angles.fajrTwilightAngle != 0;
}


DataModelWrapper::~DataModelWrapper() {
	m_model.setParent(NULL);
}

} /* namespace salat */
