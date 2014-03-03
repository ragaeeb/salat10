#include "ClockUtil.h"

#include <bps/clock.h>

namespace canadainc {

ClockUtil::ClockUtil(QObject* parent) : QObject(parent)
{
    subscribe( clock_get_domain() );
    clock_request_events(0);
}


void ClockUtil::event(bps_event_t* event)
{
    if ( event && bps_event_get_domain(event) == clock_get_domain() )
    {
        //int dateChanged(clock_event_get_date_change(event));
        //QString timezoneChanged(clock_event_get_time_zone_change(event));
        // Diff existing timezone? These events are quite rare, pushing a change event shouldn't be a big deal.

        emit clockSettingsChanged();
    }
}


ClockUtil::~ClockUtil()
{
}

} /* namespace canadainc */
