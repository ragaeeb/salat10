#include "precompiled.h"

#include "CleanupEvents.h"
#include "Logger.h"

namespace salat {

using namespace bb::pim::calendar;

CleanupEvents::CleanupEvents() : m_quit(false)
{

}


void CleanupEvents::cancel() {
    m_quit = true;
}


void CleanupEvents::run()
{
	LOGGER("CleanupEvents::run() executing");

	CalendarService calendarService;

	EventSearchParameters params;
	QDateTime now = QDateTime::currentDateTime();
	params.setStart( now.addYears(-1) );
	params.setPrefix("Salat10:");
	params.setEnd( now.addYears(1) );
	params.setDetails(DetailLevel::Monthly);

	QList<CalendarEvent> evs = calendarService.events(params);
	int total = evs.size();

	for (int i = 0; i < total; i++)
	{
	    if (m_quit) {
	        return;
	    }

		calendarService.deleteEvent(evs[i]);
		emit progress(i, total);
	}

	emit progress(total, total);

	LOGGER("CleanupEvents::run() finished after running " << total);
}


CleanupEvents::~CleanupEvents()
{
}


} /* namespace salat10 */
