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
    if ( event && bps_event_get_domain(event) == clock_get_domain() ) {
        emit clockSettingsChanged();
    }
}


ClockUtil::~ClockUtil()
{
}

} /* namespace canadainc */
