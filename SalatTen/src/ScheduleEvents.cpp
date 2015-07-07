#include "precompiled.h"

#include "ScheduleEvents.h"
#include "Calculator.h"
#include "Coordinates.h"
#include "Logger.h"
#include "SalatParameters.h"
#include "SalatUtils.h"
#include "Translator.h"

using namespace bb::pim::calendar;

#define key_hour_of_response "hourResponse"

namespace {

void schedule(CalendarService& service, CalendarEvent& ev, qint64 accountId, QString const& subject, QDateTime const& startTime, QDateTime const& endTime, QString const& body=QString())
{
    LOGGER(subject << startTime << endTime);

    EventSearchParameters params;
    params.setStart(startTime);
    params.setEnd(endTime);
    params.setPrefix(subject);
    params.setDetails(DetailLevel::Monthly);

    QList<CalendarEvent> evs = service.events(params);

    if ( evs.isEmpty() )
    {
        ev.setAccountId(accountId);
        ev.setFolderId(1);
        ev.setStartTime(startTime);
        ev.setEndTime(endTime);
        ev.setSubject(subject);

        if ( !body.isNull() ) {
            ev.setBody(body);
        }

        service.createEvent(ev);
    } else {
        LOGGER("ScheduleEvent::run() duplicate calendar event found, not scheduling");
    }
}

}

namespace salat {

using namespace bb::system;
using namespace bb;

ScheduleEvents::ScheduleEvents(int numDays, QMap<QString,int> const& events, qint64 accountId) :
		m_numDays(numDays), m_events(events), m_accountId(accountId), m_quit(false)
{
}


void ScheduleEvents::cancel()
{
    m_quit = true;
    LOGGER("cancelling" << m_quit);
}


void ScheduleEvents::run()
{
	LOGGER(m_events);

	Calculator calculator;
    CalendarService service;
    CalendarEvent ev;

    QSettings settings;
	qreal latitude = settings.value(KEY_CALC_LATITUDE).toReal();
	qreal longitude = settings.value(KEY_CALC_LONGITUDE).toReal();
    qreal asrRatio = settings.value(KEY_CALC_ASR_RATIO).toReal();
	SalatParameters angles = Calculator::createParams( settings.value(KEY_CALC_ANGLES).toMap() );
    QStringList keys = Translator::eventKeys();
    Translator t;

    QMap<QString, int> adjustments;
    QVariantMap adjustmentMap = settings.value(KEY_CALC_ADJUSTMENTS).toMap();

    foreach ( QString const& key, adjustmentMap.keys() ) {
        adjustments.insert( key, adjustmentMap[key].toInt() );
    }

	QDateTime current = QDateTime::currentDateTime();

	for (int i = 0; i < m_numDays; i++)
	{
	    Coordinates geo = Calculator::createCoordinates(current, latitude, longitude);
	    QList<QDateTime> result = calculator.calculate( current.date(), geo, angles, asrRatio );

	    for (int j = 0; j <= index_isha; j++)
	    {
	        if (j == index_sunrise) {
	            continue;
	        }

	        QString currentKey = keys[j];
	        QDateTime value = result[j].addSecs( adjustments.value(currentKey)*60 );

	        if ( (j == index_maghrib) && ( value.date().dayOfWeek() == Qt::Friday ) && m_events.contains(key_hour_of_response) )
	        {
	            int minuteAdjustment = m_events.value(key_hour_of_response);
	            QDateTime endTime = value;
	            QDateTime startTime = endTime.addSecs(minuteAdjustment*60);
	            QString eventName = tr("Salat10: Hour of Response");
	            QString body = trUtf8("Narrated by Jaabir ibn ‘Abdillah (may Allah be pleased with him) who said:\n\nThe Messenger of Allah (صلى الله عليه وسلم) said:\n\n“The day of Friday has twelve hours, in which there is no Muslim slave who asks Allah for anything but He will grant it to him, so seek it in the last hour after ‘Asr.”\n\nReported by Abu Dawood (1048) and an-Nasaa’i (1389); classed as saheeh by al-Albaani in Saheeh Abi Dawood; and by an-Nawawi in al-Majmoo‘, 4/471");

	            schedule(service, ev, m_accountId, eventName, startTime, endTime, body);
	        }

	        if ( m_events.contains(currentKey) )
	        {
	            int minuteAdjustment = m_events.value(currentKey);
	            QDateTime startTime = value.addSecs(minuteAdjustment*60);
	            QString nextKey = keys[j+1];
	            QDateTime endTime = result[j+1].addSecs( adjustments.value(nextKey)*60 );
	            QString eventName = t.render(currentKey);

	            QString subject;

	            if (minuteAdjustment == 0) {
	                 subject = tr("Salat10: %1").arg(eventName);
	            } else if (minuteAdjustment > 0) {
	                subject = tr("Salat10: %1 started %2 minutes ago").arg(eventName).arg(minuteAdjustment);
	            } else if (minuteAdjustment < 0) {
	                subject = tr("Salat10: %1 in %2 minutes").arg(eventName).arg( abs(minuteAdjustment) );
	            }

	            schedule(service, ev, m_accountId, subject, startTime, endTime);
	        }

            if (m_quit) {
                return;
            }
	    }

	    current = current.addDays(1);

	    emit progress(i, m_numDays);
	}

    emit progress(m_numDays, m_numDays);
}

ScheduleEvents::~ScheduleEvents()
{
}

} /* namespace salat10 */
