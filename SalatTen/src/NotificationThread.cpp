#include "precompiled.h"

#include "NotificationThread.h"
#include "AppLogFetcher.h"
#include "CommonConstants.h"
#include "DataModelWrapper.h"
#include "Logger.h"
#include "IOUtils.h"
#include "Persistance.h"
#include "ReportGenerator.h"
#include "SalatUtils.h"
#include "Translator.h"
#include "ThreadUtils.h"

#define COOKIE_GEO_FETCH "geo"
#define COOKIE_IP1_FETCH "ip"
#define COOKIE_IP2_FETCH "ip2"

namespace {

QString encode(QString const& toEncode) {
    return QString( QUrl(toEncode).toEncoded() );
}

QString decode(QString const& toDecode) {
    return QUrl::fromEncoded( toDecode.toUtf8() ).toString();
}

QUrl generateHostUrl(QString const& path)
{
    QUrl url;
    url.setScheme("http");
    url.setUserName("username");
    url.setPassword("password");
    url.setHost("host.com");
    url.setPath("/path/"+path);
    return url;
}

}

namespace salat {

using namespace canadainc;
using namespace bb::cascades;
using namespace bb::system;

NotificationThread::NotificationThread(DataModelWrapper* model, QObject* parent) :
        QObject(parent), m_model(model)
{
    connect( &m_clock, SIGNAL( clockSettingsChanged() ), this, SLOT( timeout() ) );

	m_timer.setSingleShot(true);
	connect( &m_timer, SIGNAL( timeout() ), this, SLOT( timeout() ) );
	connect( m_model, SIGNAL( recalculationNeeded() ), this, SLOT( timeout() ) );

    connect( &m_network, SIGNAL( requestComplete(QVariant const&, QByteArray const&, bool) ), this, SLOT( requestComplete(QVariant const&, QByteArray const&, bool) ) );
}


void NotificationThread::timeout()
{
    if ( m_model->calculationFeasible() )
    {
        QDateTime now = QDateTime::currentDateTime();

        emit currentEventChanged();

        QVariantMap next = m_model->getNext(now);

        qint64 diff = next.value(PRAYER_TIME_VALUE).toDateTime().toMSecsSinceEpoch() - now.toMSecsSinceEpoch();
        m_timer.start(diff);

        LOGGER("StartedTimerFor" << diff);
    }
}


void NotificationThread::geoLookup(QString const& location)
{
    QUrl url;
    url.setScheme("https");
    url.setHost("maps.googleapis.com");
    url.setPath("maps/api/geocode/json");
    url.addQueryItem("key", "api-key");
    url.addQueryItem("address", location);

    m_network.doGet(url, COOKIE_GEO_FETCH);
}


void NotificationThread::processIP1(QByteArray const& data)
{
    QVariantMap result = bb::data::JsonDataAccess().loadFromBuffer(data).toMap();

    if ( result.contains("latitude") && result.contains("longitude") )
    {
        qreal latitude = result.value("latitude").toReal();
        qreal longitude = result.value("longitude").toReal();
        QString country = result.value("country").toString();
        QString city = result.value("city").toString();
        QString region = result.value("region").toString();

        saveLocation(country, city, latitude, longitude, region);
    } else if ( m_network.online() ) {
        m_network.doGet( QUrl("http://www.freegeoip.net/csv/"), COOKIE_IP2_FETCH); // try a different provider
        AppLogFetcher::getInstance()->record("FailedIP1FetchIP2");
    } else {
        LOGGER("OfflineDontFetchIP2");
        AppLogFetcher::getInstance()->record("OfflineDontFetchIP2");
    }
}


void NotificationThread::processIP2(QByteArray const& data)
{
    QStringList result = QString(data).split(",");

    if ( result.size() > 9 )
    {
        QString country = result[2];
        QString city = result[5];
        qreal latitude = result[8].toDouble();
        qreal longitude = result[9].toDouble();

        saveLocation(country, city, latitude, longitude);
    } else {
        LOGGER("GEOIP_ERROR: BothLookupsFailed!");
        AppLogFetcher::getInstance()->record("BothLookupsFailed");
    }
}


void NotificationThread::requestComplete(QVariant const& cookie, QByteArray const& data, bool error)
{
    LOGGER( cookie << data.size() << error );

    if (cookie == COOKIE_GEO_FETCH) {
        QVariant result = bb::data::JsonDataAccess().loadFromBuffer(data);
        emit locationsFound(result);
    } else if (cookie == COOKIE_IP1_FETCH) {
        processIP1(data);
    } else if (cookie == COOKIE_IP2_FETCH) {
        processIP2(data);
    }
}


void NotificationThread::saveLocation(QString const& country, QString city, qreal latitude, qreal longitude, QString const& region)
{
    if ( !m_model->calculationFeasible() ) // if in the meantime the GPS (a more accurate one overrode it)
    {
        AppLogFetcher* alf = AppLogFetcher::getInstance();

        if ( !country.isEmpty() ) {
            m_model->getPersist()->saveValueFor(KEY_COUNTRY, country, false);
            alf->record(KEY_COUNTRY, country);
        }

        if ( !city.isEmpty() ) {
            m_model->getPersist()->saveValueFor(KEY_CITY, city, false);
            alf->record(KEY_CITY, city);
        } else {
            city = region;
        }

        if ( !country.isEmpty() && !city.isEmpty() ) {
            m_model->getPersist()->saveValueFor(KEY_LOCATION, QString("%1, %2").arg(city).arg(country), false);
        } else if ( !city.isEmpty() ) {
            m_model->getPersist()->saveValueFor(KEY_LOCATION, city, false);
        } else if ( !country.isEmpty() ) {
            m_model->getPersist()->saveValueFor(KEY_LOCATION, country, false);
        }

        m_model->getPersist()->saveValueFor(KEY_CALC_LATITUDE, latitude);
        m_model->getPersist()->saveValueFor(KEY_CALC_LONGITUDE, longitude);

        alf->record( KEY_CALC_LATITUDE, QString::number(latitude) );
        alf->record( KEY_CALC_LONGITUDE, QString::number(longitude) );
    }
}


void NotificationThread::ipLookup()
{
    if ( m_network.online() ) {
        m_network.doGet( QUrl("http://www.telize.com/geoip"), COOKIE_IP1_FETCH);
    } else {
        LOGGER("OfflineDontFetchIP1");
        AppLogFetcher::getInstance()->record("OfflineDontFetchIP1");
    }
}


NotificationThread::~NotificationThread()
{
}

} /* namespace salat */
