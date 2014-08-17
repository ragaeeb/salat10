#include "Calculator.h"
#include "Coordinates.h"
#include "SalatParameters.h"

#include <math.h>
#include <QDateTime>

#define height_ratio 12/M_PI // The ratio to the height.
#define linear_ratio 0.45
#define maxHourValue 23
#define maxMinuteValue 59
#define minimumSecond 0
#define multiplier 1.3369
#define safety_time 0.016389 // Safety time used to give some room for error handling. //(59/TimeFormatter.TOTAL_SECONDS_IN_MINUTE)/TimeFormatter.TOTAL_MINUTES_IN_HOUR; // but times are off with IslamicFinder
#define total_seconds_in_minute 60
#define totalHoursInDay 24
#define totalMinutesInHour 60

namespace {

using namespace salat;

/**
 * Computes the height value given the ratio.
 * @param cH The ratio used to calculate the correct height value.
 * @return The correct height value.
 */
qreal computeH(qreal cH) {
    return acos(cH) * height_ratio;
}


/**
 * Gets the time object associated with the raw time data specified.
 * @param time The raw prayer time value to create a user friendly version of. For
 * example 4:30.00 AM would be 4.5, and 11:30.00 PM would be 23.5.
 * @param intervalAddition The extra amount to add to the minutes.
 * @param date The date the time falls under.
 * @return The time object associated with the raw time data specified in string format "hh:mm:ss"
 */
QDateTime computeDate(qreal time, qreal intervalAddition, QDate const& dateValue)
{
	int hour = floor(time);
	int min = floor( 60*(time-hour) );
	int sec = floor( 3600.0*( time - hour - min/60.0 ) );

	if ( sec > total_seconds_in_minute/2 ) {
		min = min + 1; // go to next minute if seconds are more than 30.
    }

	if ( sec == total_seconds_in_minute )
	{
		min++;
		sec = minimumSecond;
	}

	sec = abs(sec);
	min = abs(min);
	hour = abs(hour);

	min += intervalAddition;

	while ( min > maxMinuteValue ) // Adjust the minutes. Minutes must be less than 60.
	{
		min = min - totalMinutesInHour;
		hour++;
	}

	while ( hour > maxHourValue ) {
	    // Adjust the hours. Hours must be less than 24.
		hour = hour - totalHoursInDay;
	}

	return QDateTime( dateValue, QTime(hour, min, sec) );
}

qreal getMaximumAngle() { // the maximum isha angle
	return SolarCalculator::degreesToRadians(48);
}

QList<QDateTime> initList()
{
    QList<QDateTime> todayResults;
    for (int i = index_fajr; i <= index_lastThirdNight; i++) {
    	todayResults << QDateTime();
    }

    return todayResults;
}

}


namespace salat {

Calculator::Calculator()
{
}


Coordinates Calculator::createCoordinates(QDateTime local, qreal latitude, qreal longitude)
{
	QDateTime utc = local.toUTC();
	local.setTimeSpec(Qt::UTC);

	Coordinates geo; // timezoneoffset returns -4 instead of -5 if daylight savings is in effect
	geo.timeZone = -utc.secsTo(local) / 3600;
	geo.position.setX( SolarCalculator::degreesToRadians(latitude) );
	geo.position.setY( SolarCalculator::degreesToRadians(longitude) );

	return geo;
}


SalatParameters Calculator::createParams(QVariantMap const& angleMap)
{
	SalatParameters angles;
	angles.dhuhrInterval = angleMap["dhuhrInterval"].toReal();
	angles.fajrTwilightAngle = SolarCalculator::degreesToRadians( angleMap["fajrTwilightAngle"].toReal() );
	angles.ishaInterval = angleMap["ishaInterval"].toReal();
	angles.ishaTwilightAngle = SolarCalculator::degreesToRadians( angleMap["ishaTwilightAngle"].toReal() );
	angles.maghribInterval = angleMap["maghribInterval"].toReal();

	return angles;
}


/**
 * Calculates the prayer times for the specified geographical parameters and date.
 * @param fixedDate The date to perform the solar prayer time calculations for.
 * @param g The geographical coordinates of the location to calculate the prayer times for.
 * @param angles Twilight angles needed to compute fajr & isha times.
 * @param asrRatio The ratio of the length of the object to its shadow at noon.
 * @return The prayer times for the requested geographical coordinates and specified date.
 */
QList<QDateTime> Calculator::calculate(QDate const& fixedDate, Coordinates const& geo, SalatParameters const& angles, qreal asrRatio)
{
    // get today's results
    QList<QDateTime> todayResults = initList();

	bool problematic = m_solar.calculateSolar( fixedDate, geo.timeZone, geo.position.y(), geo.position.x() ); // perform initial calculation
	todayResults[index_sunrise] = computeDate( m_solar.getSunrise(), 0, fixedDate );
	todayResults[index_dhuhr] = computeDate( m_solar.getNoonTime()+safety_time, floor( angles.dhuhrInterval ), fixedDate ); // Dhuhr time+extra time to make sure that the sun has moved from zawal
	todayResults[index_maghrib] = computeDate( m_solar.getSunset(), floor( angles.maghribInterval ), fixedDate );
	todayResults[index_asr] = computeDate( computeAsr(problematic, geo.position.x(), asrRatio), 0, fixedDate );
	calculateFajrIsha(fixedDate, geo, angles, todayResults);

    // get tomorrow's results
    QDate tomorrowDate = fixedDate.addDays(1);
    QList<QDateTime> tomorrowResults = initList();
    calculateFajrIsha(tomorrowDate, geo, angles, tomorrowResults);

    qint64 fajrTomorrow = tomorrowResults[index_fajr].toMSecsSinceEpoch();
    qint64 maghribToday = todayResults[index_maghrib].toMSecsSinceEpoch();

    qint64 diff = fajrTomorrow-maghribToday;
    qint64 delta = diff/2; // (18-12)/2 = 3
    QDateTime halfNight = QDateTime::fromMSecsSinceEpoch(maghribToday+delta); // 12+3 = 15 = 3pm
    todayResults[index_halfNight] = halfNight;

    delta = diff/3; // 9pm-12pm ( 21-12 = 9 )/3 = 3

    qint64 lastThird = fajrTomorrow-delta;
    todayResults[index_lastThirdNight] = QDateTime::fromMSecsSinceEpoch(lastThird);

    return todayResults;
}


void Calculator::calculateFajrIsha(QDate const& fixedDate, Coordinates const& geo, SalatParameters const& angles, QList<QDateTime>& results)
{
	bool fajrInSolstice = !computeFajr( angles.fajrTwilightAngle, geo.position.x(), fixedDate, results );
	bool ishaInSolstice = !computeIsha( angles.ishaTwilightAngle, angles.ishaInterval, geo.position.x(), fixedDate, results );

	if (fajrInSolstice || ishaInSolstice) {
	    computeFajrIshaInSolstice(geo, angles, fixedDate, fajrInSolstice, ishaInSolstice, results);
	}
}


/**
 * Computes the Fajr prayer time.
 * @param fajrTwilight The Fajr twilight angle.
 * @param latitude The latitude to use when calculating the Asr prayer start time.
 * @param fixedDate The date to perform the Fajr calculation for.
 * @return <code>true</code> if the Fajr time was successfully calculated since we are not in solstice, <code>false</code> if we were
 * not able to properly compute the Fajr time since we are in solstice.
 */
bool Calculator::computeFajr(qreal fajrTwilight, qreal latitude, QDate const& fixedDate, QList<QDateTime>& results)
{
	qreal angle = -fajrTwilight; // The value -19deg is used by OmAlqrah for Fajr, but it is not correct. Astronomical twilight and Rabita use -18deg
	qreal cH = m_solar.calculateCorrectedHeight(angle);
	bool lessThan48 = abs(latitude) < getMaximumAngle();
	bool notInSolstice = abs(cH) <= (linear_ratio + multiplier*fajrTwilight);

	if (lessThan48 || notInSolstice) // If latitude is < 48 degrees: no problem
	{
	    qreal result = m_solar.getNoonTime() - computeH(cH) + safety_time;
	    results[index_fajr] = computeDate(result, 0, fixedDate);

		return true;
	}

	return false; // in solstice, need to calculate differently
}



/**
 * Computes the Isha prayer time.
 * @param ishaTwilight The Isha twilight angle.
 * @param ishaInterval The Isha prayer interval addition.
 * @param latitude The latitude in radians of the location to calculate the Isha prayer for.
 * @param fixedDate The date to perform the Isha calculation for.
 * @return <code>true</code> if the Isha time was successfully calculated since we are not in solstice, <code>false</code> if we were
 * not able to properly compute the Isha time since we are in solstice.
 */
bool Calculator::computeIsha(qreal ishaTwilight, qreal ishaInterval, qreal latitude, QDate const& fixedDate, QList<QDateTime>& results)
{
	qreal angle = -ishaTwilight;
	qreal cH = m_solar.calculateCorrectedHeight(angle);
	bool lessThan48 = abs(latitude) < getMaximumAngle();
	bool notInSolstice = abs(cH) <= (linear_ratio + multiplier*ishaTwilight);

    if (ishaTwilight == 0) {
        qreal result = m_solar.getSunset() + ishaInterval; // Isha time OmAlqrah standard Sunset + fixed time (1.5 hours or 2 hours in Ramadan)
        results[index_isha] = computeDate(result, ishaInterval, fixedDate); // TODO: This seems wrong, why are we adding ishaInterval twice?

        return true;
    } else if (lessThan48 || notInSolstice) {
        qreal result = m_solar.getNoonTime() + computeH(cH) + safety_time; // Isha time, instead of Sunset+1.5h
        results[index_isha] = computeDate(result, ishaInterval, fixedDate); // TODO: This seems wrong, why are we adding ishaInterval twice?

        return true;
    }

    return false;
}



/* Computes the Fajr or Isha prayer under the solstice conditions.
 * The cause of the seasons is that the Earth's axis of rotation is not
 * perpendicular to its orbital plane (the flat plane made through the
 * center of mass (barycenter) of the solar system (near or within the
 * Sun) and the successive locations of Earth during the year), but
 * currently makes an angle of about 23.44� (called the "obliquity of the
 * ecliptic"), and that the axis keeps its orientation with respect to
 * inertial space. As a consequence, for half the year (from around 20
 * March to 22 September) the northern hemisphere is inclined toward the
 * Sun, with the maximum around 21 June, while for the other half year
 * the southern hemisphere has this distinction, with the maximum around
 * 21 December. The two moments when the inclination of Earth's rotational
 * axis has maximum effect are the solstices. [1]
 *
 * [1] Wikipedia, (2009). Solstice. [Online]. Available:
 * http://en.wikipedia.org/wiki/Solstice [June 21, 2009]
 *
 * @param latitude
 * @param fixedDate
 */
void Calculator::computeFajrIshaInSolstice(Coordinates const& geo, SalatParameters const& angles, QDate const& fixedDate, bool fajrInSolstice, bool ishaInSolstice, QList<QDateTime>& results)
{
    QDate myDate(fixedDate);

    if ( geo.position.x() < 0 ) {
    	myDate.setDate( fixedDate.year(), 12, 21 ); // december 21
    } else {
    	myDate.setDate( fixedDate.year(), 6, 21 ); // june 21
    }

    qreal sunrise = m_solar.getSunrise();
    qreal sunset = m_solar.getSunset();
    qreal nightLength = m_solar.getNightLength();
    qreal maxLatitude = SolarCalculator::degreesToRadians(45); // There are problems in computing sun(rise,set)

    if ( geo.position.x() < 0 ) {
    	maxLatitude = -maxLatitude;
    }

    m_solar.performCalculationSolar( myDate, geo.timeZone, geo.position.y(), maxLatitude );

    qreal night = m_solar.getNightLength();

	if (fajrInSolstice)
	{
	    qreal angle = -angles.fajrTwilightAngle;
		qreal cH = m_solar.calculateCorrectedHeight(angle);
		qreal H = computeH(cH);
		qreal fajrReference = m_solar.getNoonTime() - H - safety_time;
		qreal fajrStart = (m_solar.getSunrise()-fajrReference)/night;

	    qreal result = sunrise - nightLength*fajrStart; // According to the general ratio rule
	    results[index_fajr] = computeDate(result, 0, fixedDate);
	}

	if (ishaInSolstice)
	{
		qreal ishaTwilight = -angles.ishaTwilightAngle;
		qreal ishaReference = m_solar.getSunset() + angles.ishaInterval;

		if (ishaTwilight != 0)
		{
			qreal cH = m_solar.calculateCorrectedHeight(ishaTwilight);
			qreal H = computeH(cH);
			ishaReference = m_solar.getNoonTime() + H + safety_time;
		}

		qreal ishaStart = ( ishaReference - m_solar.getSunset() )/night;
	    //qreal result = m_solar.getSunset() + nightLength*ishastart; // According to the Rabita method.
		qreal result = sunset + nightLength*ishaStart; // According to the Rabita method.
	    results[index_isha] = computeDate(result, angles.ishaInterval, fixedDate); // TODO: This seems wrong, why are we adding ishaInterval twice?
	}
}


/**
 * Computes the Asr prayer time.
 * @param problematic Was the solar calculation problematic?
 * @param latitude The latitude to use when calculating the Asr prayer start time.
 * @param asrRatio The angle ratio.
 * @return The Asr time.
 */
qreal Calculator::computeAsr(bool problematic, qreal latitude, qreal asrRatio)
{
	qreal difference = m_solar.getEquatorialCoordinates().x();

	if (problematic) {
	    // for places above 65 degrees
	    difference -= m_solar.getMaxLatitude();
	} else { // no problem
		difference -= latitude; // In the standard equations abs() is not used, but it is required for -ve latitude
	}

	qreal act = asrRatio + tan( abs(difference) );
	qreal angle = atan(1.0/act);
	qreal cH = m_solar.calculateCorrectedHeight(angle);

	qreal H = 3.5;

	if( abs(cH) <= 1.0 ) {
	    H = computeH(cH);
	}

	return m_solar.getNoonTime()+H+safety_time;
}


Calculator::~Calculator()
{
}

} /* namespace salat10 */
