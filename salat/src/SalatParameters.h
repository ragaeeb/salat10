#ifndef SALATPARAMETERS_H_
#define SALATPARAMETERS_H_

#include <QMetaType>

namespace salat {

struct SalatParameters
{
	qreal fajrTwilightAngle;
	qreal ishaTwilightAngle;
	qreal dhuhrInterval;
	qreal ishaInterval; // The difference of Isha time from Maghrib.
	qreal maghribInterval; // The number of minutes to add to the sunset time for the Maghrib prayer time.
};

} /* namespace salat */

Q_DECLARE_METATYPE(salat::SalatParameters)

#endif /* SALATPARAMETERS_H_ */
