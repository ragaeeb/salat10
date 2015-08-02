#include "precompiled.h"

#include "DataModelWrapper.h"
#include "Coordinates.h"
#include "Logger.h"
#include "Persistance.h"
#include "SalatUtils.h"
#include "SolarCalculator.h"
#include "Translator.h"
#include "ThreadUtils.h"

namespace salat {

using namespace bb::cascades;

DataModelWrapper::DataModelWrapper(Persistance* p, QObject* parent) :
        QObject(parent), m_persistance(p),
        m_model( QStringList() << KEY_SORT_DATE, this )
{
	m_model.setSortingKeys( QStringList() << KEY_SORT_DATE << PRAYER_TIME_VALUE );
	m_model.setGrouping(ItemGrouping::ByFullValue);

	connect( p, SIGNAL( settingChanged(QString const&) ), this, SLOT( settingChanged(QString const&) ), Qt::QueuedConnection );
}


void DataModelWrapper::lazyInit()
{
    updateCache( QStringList() << KEY_CALC_ANGLES << KEY_CALC_ASR_RATIO << KEY_CALC_ADJUSTMENTS << KEY_ATHANS << KEY_NOTIFICATIONS << KEY_IQAMAHS << KEY_CALC_LATITUDE << KEY_CALC_LONGITUDE << KEY_ISHA_NIGHT << KEY_DST_ADJUST );

    Coordinates geo = Calculator::createCoordinates( QDateTime::currentDateTime(), m_cache.latitude, m_cache.longitude );
    LOGGER(geo.name << geo.position << geo.timeZone);
}


QVariantList DataModelWrapper::calculate(QDateTime local, int numDays)
{
    QMap<QString, bool> salatMap = Translator().salatMap();
    Coordinates geo = Calculator::createCoordinates(local, m_cache.latitude, m_cache.longitude);

	QVariantList wrapped;
	QStringList keys = Translator::eventKeys();

	for (int i = 0; i < numDays; i++)
	{
		QList<QDateTime> result = m_calculator.calculate( local.date(), geo, m_cache.angles, m_cache.asrRatio, m_cache.nightStartsIsha );
		//	result << local.addSecs(30) << local.addSecs(60) << local.addSecs(90) << local.addSecs(120) << local.addSecs(150) << local.addSecs(180) << local.addSecs(210) << local.addSecs(240) << local.addSecs(270);

		LOGGER(result);

		for (int j = 0; j < result.size(); j++)
		{
			QString key = keys[j];
			int adjust = m_cache.adjustments.value(key);

			QVariantMap map;
			map[PRAYER_KEY] = key;
			map[PRAYER_TIME_VALUE] = result[j].addSecs(adjust*60).addSecs(m_cache.dstAdjust*3600);
			map[KEY_SORT_DATE] = result[j].date();
			map["isSalat"] = salatMap.contains(key);

			if ( m_cache.iqamahs.contains(key) )
			{
	            QDateTime iqamah = QDateTime( result[j].date(), m_cache.iqamahs.value(key) );
	            map[KEY_IQAMAH] = iqamah;
			}

			if ( m_cache.athaans.contains(key) ) {
				map[KEY_ATHAN] = m_cache.athaans.value(key);
			}

            if ( m_cache.notifications.contains(key) ) {
                map[KEY_ALARM_NOTIFICATION] = m_cache.notifications.value(key);
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
	map[KEY_SORT_DATE] = reference.date();
	map[PRAYER_TIME_VALUE] = reference;

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
	QDateTime reference = m_model.data( m_model.first() ).toMap().value(PRAYER_TIME_VALUE).toDateTime().addDays(-1);
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
            current[itemKey] = settingValue.value( current.value(PRAYER_KEY).toString() );
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
			} else if ( m_model.data(prev).toMap().value(PRAYER_KEY) != key_fajr ) {
				i = prev;
			} else {
				break;
			}
		}

		QDateTime reference = m_model.data(i).toMap().value(PRAYER_TIME_VALUE).toDateTime().addDays(1);
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
        if (key == KEY_CALC_ANGLES) {
            m_cache.angles = Calculator::createParams( m_persistance->getValueFor(KEY_CALC_ANGLES).toMap() );
            needsRefresh = true;
        } else if (key == KEY_CALC_ASR_RATIO) {
            m_cache.asrRatio = m_persistance->getValueFor(KEY_CALC_ASR_RATIO).toReal();
            needsRefresh = true;
        } else if (key == KEY_CALC_ADJUSTMENTS) {
            QVariantMap adjustments = m_persistance->getValueFor(KEY_CALC_ADJUSTMENTS).toMap();
            m_cache.adjustments.clear();

            foreach ( QString const& key, adjustments.keys() ) {
                m_cache.adjustments.insert( key, adjustments[key].toInt() );
            }

            needsRefresh = true;
        } else if (key == KEY_ATHANS) {
            m_cache.athaans = m_persistance->getValueFor(KEY_ATHANS).toMap();
            applyDiff(key, KEY_ATHAN);
        } else if (key == KEY_NOTIFICATIONS) {
            m_cache.notifications = m_persistance->getValueFor(KEY_NOTIFICATIONS).toMap();
            applyDiff(key, KEY_ALARM_NOTIFICATION);
        } else if (key == KEY_DST_ADJUST) {
            m_cache.dstAdjust = m_persistance->getValueFor(KEY_DST_ADJUST).toInt();
            needsRefresh = true;
        } else if (key == KEY_IQAMAHS) {
            QVariantMap iqamahs = m_persistance->getValueFor(KEY_IQAMAHS).toMap();
            m_cache.iqamahs.clear();

            foreach ( QString const& key, iqamahs.keys() ) {
                m_cache.iqamahs.insert( key, iqamahs[key].toTime() );
            }

            ThreadUtils::diffIqamahs(&m_model, m_cache.iqamahs);
        } else if (key == KEY_CALC_LATITUDE) {
            m_cache.latitude = m_persistance->getValueFor(KEY_CALC_LATITUDE).toReal();
            needsRefresh = true;
        } else if (key == KEY_CALC_LONGITUDE) {
            m_cache.longitude = m_persistance->getValueFor(KEY_CALC_LONGITUDE).toReal();
            needsRefresh = true;
        } else if (key == KEY_ISHA_NIGHT) {
            m_cache.nightStartsIsha = m_persistance->getValueFor(KEY_ISHA_NIGHT).toInt() == 1;
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
    return latitude != 0 && longitude != 0 && anglesSet();
}


bool DataModelWrapper::anglesSaved() const {
    return m_cache.anglesSet();
}


bool Cache::anglesSet() const {
    return angles.fajrTwilightAngle != 0;
}


int DataModelWrapper::dstAdjustment() const {
    return m_cache.dstAdjust;
}


DataModelWrapper::~DataModelWrapper() {
	m_model.setParent(NULL);
}

} /* namespace salat */
