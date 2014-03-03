#include "precompiled.h"

#include "ScheduleEvents.h"
#include "DataModelWrapper.h"
#include "Logger.h"

using namespace bb::pim::calendar;

namespace {

const char* key_hour_of_response = "hourResponse";

void schedule(CalendarService& service, CalendarEvent& ev, int accountId, QString const& subject, QDateTime const& startTime, QDateTime const& endTime, QString const& body=QString())
{
    LOGGER("======== Saving" << subject << startTime << endTime);

    EventSearchParameters params;
    params.setStart(startTime);
    params.setEnd(endTime);
    params.setPrefix(subject);
    params.setDetails(DetailLevel::Monthly);

    QList<CalendarEvent> evs = service.events(params);

    if ( evs.isEmpty() ) {
        LOGGER("ScheduleEvent::run() no duplicates found, scheduling");

        ev.setAccountId(accountId);
        ev.setFolderId(1);
        ev.setStartTime(startTime);
        ev.setEndTime(endTime);
        ev.setSubject(subject);

        if ( !body.isNull() ) {
            ev.setBody(body);
        }

        LOGGER("Set body" << body);

        service.createEvent(ev);

        LOGGER("===== Current one" << ev.id());
    } else {
        LOGGER("ScheduleEvent::run() duplicate calendar event found, not scheduling");
    }
}

}

namespace salat {

using namespace bb::system;
using namespace bb;

ScheduleEvents::ScheduleEvents(DataModelWrapper* model, int numDays, QMap<QString,int> const& events, int accountId) :
		m_numDays(numDays), m_events(events), m_model(model), m_accountId(accountId), m_quit(false)
{
}


void ScheduleEvents::cancel()
{
    m_quit = true;
    LOGGER("cancelling" << m_quit);
}


void ScheduleEvents::run()
{
	LOGGER("Run: " << m_events);

	QVariantList results = m_model->calculate( QDateTime::currentDateTime(), m_numDays );
	CalendarService service;
    CalendarEvent ev;

	int total = results.size()-3; // we don't need to consider the very last first 1/3 night ends, half-night begins, last 1/3 night begins

    for (int i = 0; i < total; i++)
    {
    	QVariantMap current = results[i].toMap();
    	QString currentKey = current.value("key").toString();

    	LOGGER("m_quit" << m_quit);

    	QDateTime value = current.value("value").toDateTime();

    	if ( currentKey == Translator::key_maghrib && value.date().dayOfWeek() == Qt::Friday && m_events.contains(key_hour_of_response) )
    	{
            int minuteAdjustment = m_events.value(key_hour_of_response);
            QDateTime endTime = value;
            QDateTime startTime = endTime.addSecs(minuteAdjustment*60);
            QString eventName = tr("Salat10: Hour of Response");
            QString body = trUtf8("Narrated by Jaabir ibn ‘Abdillah (may Allah be pleased with him) who said:\n\nThe Messenger of Allah (صلى الله عليه وسلم) said:\n\n“The day of Friday has twelve hours, in which there is no Muslim slave who asks Allah for anything but He will grant it to him, so seek it in the last hour after ‘Asr.”\n\nReported by Abu Dawood (1048) and an-Nasaa’i (1389); classed as saheeh by al-Albaani in Saheeh Abi Dawood; and by an-Nawawi in al-Majmoo‘, 4/471");

            if (m_quit) {
                return;
            }

            schedule(service, ev, m_accountId, eventName, startTime, endTime, body);
    	}

    	if ( m_events.contains(currentKey) )
    	{
    		int minuteAdjustment = m_events.value(currentKey);
    		QDateTime startTime = value.addSecs(minuteAdjustment*60);
    		int forward = currentKey == "isha" ? 2 : 1;
    		QDateTime endTime = results[i+forward].toMap().value("value").toDateTime();
    		QString eventName = m_model->getTranslator()->render(currentKey);

    		QString subject;

    		if (minuteAdjustment == 0) {
    			 subject = tr("Salat10: %1").arg(eventName);
    		} else if (minuteAdjustment > 0) {
    			subject = tr("Salat10: %1 started %2 minutes ago").arg(eventName).arg(minuteAdjustment);
    		} else if (minuteAdjustment < 0) {
    			subject = tr("Salat10: %1 in %2 minutes").arg(eventName).arg( abs(minuteAdjustment) );
    		}

            if (m_quit) {
                return;
            }

    		schedule(service, ev, m_accountId, subject, startTime, endTime);
    	}

        emit progress(i, total);
    }

    emit progress(total, total);
}

ScheduleEvents::~ScheduleEvents()
{
}

} /* namespace salat10 */
