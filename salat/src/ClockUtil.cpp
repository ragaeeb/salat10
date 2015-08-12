#include "ClockUtil.h"

#include <bps/clock.h>

namespace canadainc {

ClockUtil::ClockUtil(QObject* parent) : QObject(parent), m_initialized(false)
{
    subscribe( clock_get_domain() );
    clock_request_events(0);
}


void ClockUtil::event(bps_event_t* event)
{
    if ( event && bps_event_get_domain(event) == clock_get_domain() && m_initialized ) {
        emit clockSettingsChanged();
    }

    if (!m_initialized) {
        m_initialized = true; // when this is initialized, we automatically get an event, filter out this noise
    }
}


ClockUtil::~ClockUtil()
{
}

} /* namespace canadainc */
