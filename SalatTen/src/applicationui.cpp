#include "precompiled.h"

#include "applicationui.hpp"
#include "AppLogFetcher.h"
#include "Logger.h"
#include "JlCompress.h"
#include "ReverseGeolocator.h"
#include "SalatUtils.h"
#include "SearchDecorator.h"
#include "ThreadUtils.h"

namespace salat {

using namespace bb::cascades;
using namespace bb::platform;
using namespace bb::system;
using namespace QtMobilitySubset;
using namespace canadainc;

ApplicationUI::ApplicationUI(InvokeManager* i) :
        m_locale("SalatTen", QStringList() << "salat"), m_persistance(i),
        m_cover( i->startupMode() != ApplicationStartupMode::InvokeCard, this ),
		m_model(&m_persistance), m_notification(&m_model), m_invoke(i),
		m_gpsReady(true)
{
    switch ( i->startupMode() )
    {
        case ApplicationStartupMode::LaunchApplication:
            init("main.qml");
            break;

        case ApplicationStartupMode::InvokeCard:
            connect( i, SIGNAL( cardPooled(bb::system::CardDoneMessage const&) ), QCoreApplication::instance(), SLOT( quit() ) );
            connect( i, SIGNAL( invoked(bb::system::InvokeRequest const&) ), this, SLOT( invoked(bb::system::InvokeRequest const&) ) );
            break;
        case ApplicationStartupMode::InvokeApplication:
            connect( i, SIGNAL( invoked(bb::system::InvokeRequest const&) ), this, SLOT( invoked(bb::system::InvokeRequest const&) ) );
            break;

        default:
            break;
    }

    connect( i, SIGNAL( childCardDone(bb::system::CardDoneMessage const&) ), this, SLOT( childCardDone(bb::system::CardDoneMessage const&) ) );
}


void ApplicationUI::invoked(bb::system::InvokeRequest const& request) {
    init( m_invoke.invoked(request) );
}



void ApplicationUI::init(QString const& qmlDoc)
{
    if ( !m_persistance.contains(KEY_DST_ADJUST) && m_persistance.contains(KEY_CALC_LATITUDE) )
    {
        m_persistance.portLegacy( QStringList() << KEY_CALC_LATITUDE << KEY_ATHANS << KEY_CALC_ANGLES << KEY_CALC_ASR_RATIO << KEY_CALC_ADJUSTMENTS << KEY_CALC_LATITUDE << KEY_CALC_LONGITUDE << KEY_CITY << KEY_COUNTRY << KEY_CUSTOM_ATHANS << KEY_NOTIFICATIONS << KEY_IQAMAHS );
        INIT_SETTING(KEY_DST_ADJUST, 0);
    }

    QDeclarativeContext* rootContext = QmlDocument::defaultDeclarativeEngine()->rootContext();
    rootContext->setContextProperty("boundary", &m_model);
    rootContext->setContextProperty("offloader", &m_offloader );
    rootContext->setContextProperty("translator", m_model.getTranslator() );

    QMap<QString, QObject*> context;
    context.insert( "notification", &m_notification );
    context.insert( "sql", &m_sql );

    m_invoke.init(qmlDoc, context, this);
    emit initialize();
}


void ApplicationUI::lazyInit()
{
    disconnect( this, SIGNAL( initialize() ), this, SLOT( lazyInit() ) ); // in case we get invoked again

    AppLogFetcher* apf = AppLogFetcher::create( &m_persistance, &ThreadUtils::compressFiles, this, false );
    apf->disableAnalytics();

    initDefaultValues();
    onFullScreen();

    m_invoke.registerQmlTypes();
    m_invoke.process();
    m_cover.setContext( "notification", &m_notification );

    Application* a = Application::instance();
	connect( a, SIGNAL( fullscreen() ), this, SLOT( onFullScreen() ) );
    connect( a, SIGNAL( aboutToQuit() ), this, SLOT( onFullScreen() ) );
    connect( a, SIGNAL( aboutToQuit() ), &m_offloader, SLOT( terminateThreads() ) );

    m_persistance.invoke("com.canadainc.SalatTenService", "com.canadainc.SalatTenService.RESET");

    DeviceUtils::registerTutorialTips(this);
    QmlDocument* qml = QmlDocument::create("asset:///GlobalProperties.qml").parent(this);
    qml->setContextProperty("notification", &m_notification);
    qml->setContextProperty("textUtils", &m_textUtils);
    QmlDocument::defaultDeclarativeEngine()->rootContext()->setContextProperty( "global", qml->createRootObject<QObject>() );

    qml = QmlDocument::create("asset:///HijriCalculator.qml").parent(this);
    QmlDocument::defaultDeclarativeEngine()->rootContext()->setContextProperty( "hijriCalc", qml->createRootObject<QObject>() );

    m_model.lazyInit();
	emit lazyInitComplete();
}


void ApplicationUI::initDefaultValues()
{
    INIT_SETTING(KEY_CALC_STRATEGY, KEY_CALC_STRATEGY_ISNA);
    INIT_SETTING(KEY_SKIP_JUMUAH, 1);
    INIT_SETTING(KEY_CALC_ASR_RATIO, 1);
    INIT_SETTING("hijri", 0);
    INIT_SETTING(KEY_ATHAN_VOLUME, 1.0);

    if ( !m_persistance.contains(KEY_ATHANS) )
    {
        QVariantMap notifications;

        QStringList eventKeys = Translator::eventKeys();
        QMap<QString, bool> salatMap = Translator().salatMap();

        for (int i = eventKeys.size()-1; i >= 0; i--) {
            notifications[ eventKeys[i] ] = salatMap.contains( eventKeys[i] );
        }

        m_persistance.saveValueFor(KEY_ATHANS, notifications, false);
        m_persistance.saveValueFor(KEY_NOTIFICATIONS, notifications, false);
    }

    if ( !m_persistance.contains(KEY_CALC_ADJUSTMENTS) )
    {
        QVariantMap adjustments;

        QStringList salatKeys = Translator::eventKeys();

        for (int i = salatKeys.size()-1; i >= 0; i--) {
            adjustments[ salatKeys[i] ] = 0;
        }

        m_persistance.saveValueFor(KEY_CALC_ADJUSTMENTS, adjustments);
    }

    if ( !m_persistance.contains(KEY_PROFILES) )
    {
        QVariantMap profiles;
        profiles[ QString::number(NotificationMode::Silent) ] = false;
        profiles[ QString::number(NotificationMode::Vibrate) ] = true;
        profiles[ QString::number(NotificationMode::Normal) ] = true;
        profiles[ QString::number(NotificationMode::PhoneOnly) ] = true;
        profiles[ QString::number(NotificationMode::AlertsOff) ] = false;
        profiles[ QString::number(NotificationMode::Unknown) ] = false;

        m_persistance.saveValueFor(KEY_PROFILES, profiles, false);
    }
}


void ApplicationUI::childCardDone(bb::system::CardDoneMessage const& message)
{
    LOGGER( message.data() );

    if ( !message.data().isEmpty() ) {
        m_persistance.invokeManager()->sendCardDone(message);
    }
}


bool ApplicationUI::refreshLocation()
{
    bool ok = true;

    if (m_gpsReady)
    {
        ReverseGeolocator* rgl = new ReverseGeolocator(this);
        connect( rgl, SIGNAL( finished(QGeoAddress const&, QPointF const&, bool) ), this, SLOT( reverseLookupFinished(QGeoAddress const&, QPointF const&, bool) ) );
        ok = rgl->locate();

        LOGGER(ok);

        m_gpsReady = false;
        emit gpsReadyChanged();
    }

    return ok;
}


void ApplicationUI::reverseLookupFinished(QGeoAddress const& g, QPointF const& point, bool error)
{
    LOGGER(error);

	if (!error)
	{
	    m_persistance.saveValueFor(KEY_CITY, g.city(), false );
	    m_persistance.saveValueFor(KEY_COUNTRY, g.country(), false );
	    m_persistance.saveValueFor(KEY_LOCATION, g.text(), false );
	    m_persistance.saveValueFor( KEY_CALC_LATITUDE, point.x() );
	    m_persistance.saveValueFor( KEY_CALC_LONGITUDE, point.y() );

	    AppLogFetcher* alf = AppLogFetcher::getInstance();
	    alf->record( KEY_CALC_LATITUDE, QString::number( point.x() ) );
	    alf->record( KEY_CALC_LONGITUDE, QString::number( point.y() ) );
	    alf->record( KEY_LOCATION, g.text() );

	    if ( !g.country().isEmpty() ) {
	        alf->record( KEY_COUNTRY, g.country() );
	    }

        if ( !g.city().isEmpty() ) {
            alf->record( KEY_CITY, g.city() );
        }

        resetAffectedToCanadaAngles();

	    m_persistance.showToast( tr("Location successfully set to %1!").arg( g.text() ), "images/tabs/ic_map.png" );
	} else {
	    m_persistance.showToast( tr("Location could not be detected %1!").arg( g.text() ), "images/toast/ic_location_failed.png" );
	}

	m_gpsReady = true;
	emit gpsReadyChanged();

	sender()->deleteLater();
}


void ApplicationUI::resetAffectedToCanadaAngles()
{
    if ( m_persistance.getValueFor(KEY_COUNTRY) == "Canada" )
    {
        QStringList affectedCities = QStringList() << "Ottawa" << "Toronto" << "London" << "Mississauga" << "Kanata" << "Waterloo" << "Montréal" << "Québec" << "Nepean" << "Barrie" << "Burlington" << "Cambridge" << "Guelph" << "Hamilton" << "Windsor" << "Vaughan" << "Pickering" << "Oshawa" << "Kingston" << "Niagara Falls" << "Markham" << "Kitchener";

        QString city = m_persistance.getValueFor(KEY_CITY).toString();

        if ( affectedCities.contains(city) )
        {
            QVariantMap angles;
            angles["dhuhrInterval"] = 1.0;
            angles["fajrTwilightAngle"] = 12.0;
            angles["ishaInterval"] = 1.0;
            angles["ishaTwilightAngle"] = 12.0;
            angles["maghribInterval"] = 1.0;

            m_persistance.saveValueFor("strategy", "seca", false);
            m_persistance.saveValueFor(KEY_CALC_ANGLES, angles);
        }
    }
}


void ApplicationUI::onFullScreen()
{
    bb::platform::Notification::clearEffectsForAll();
    bb::platform::Notification::deleteAllFromInbox();
}


void ApplicationUI::setCustomAthaans(QStringList const& keys, QString const& uri)
{
    LOGGER(keys << uri);

    QVariantMap athaans = m_persistance.getValueFor(KEY_CUSTOM_ATHANS).toMap();

    for (int i = keys.size()-1; i >= 0; i--) {
        athaans[ keys[i] ] = uri;
    }

    m_persistance.saveValueFor(KEY_CUSTOM_ATHANS, athaans, false);
}


void ApplicationUI::saveIqamah(QString const& key, QDateTime const& time)
{
    LOGGER(key << time);

    QVariantMap iqamahs = m_persistance.getValueFor(KEY_IQAMAHS).toMap();
    iqamahs[key] = time.time();
    m_persistance.saveValueFor(KEY_IQAMAHS, iqamahs);
}


void ApplicationUI::removeIqamah(QString const& key)
{
    LOGGER(key);

    QVariantMap iqamahs = m_persistance.getValueFor(KEY_IQAMAHS).toMap();
    iqamahs.remove(key);
    m_persistance.saveValueFor(KEY_IQAMAHS, iqamahs);
}


bool ApplicationUI::gpsReady() const {
    return m_gpsReady;
}


QString ApplicationUI::escapeHtml(QString const& input) {
    return SearchDecorator::toHtmlEscaped(input);
}


ApplicationUI::~ApplicationUI()
{
}

} // salat
